import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service, { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";
import { i18n } from "discourse-i18n";

const DEFAULT_LOCALE = "locale-en";

export default class HomepageFilter extends Service {
  @service siteSettings;

  @tracked tagFilter = null;
  @tracked topicResults = [];
  @tracked searchQuery = "";
  @tracked inputText = "";
  @tracked loading = false;
  @tracked hasMoreResults = false;
  @tracked maxResults = false;
  @tracked locale = DEFAULT_LOCALE;
  @tracked currentPage = 1;
  // search endpoint in core is currently limited to 10 pages of results
  maxPage = 10;
  initialized = false;

  get allLocale() {
    return i18n(themePrefix("navigation.all"));
  }

  initFromUrlParams() {
    if (this.initialized) {
      return;
    }
    this.initialized = true;

    const params = new URLSearchParams(window.location.search);
    const tag = params.get("tag");
    const locale = params.get("locale");
    const query = params.get("q");

    if (query) {
      this.searchQuery = query;
      this.inputText = query;
      this.tagFilter = null;
      this.locale = this.allLocale;
    } else {
      if (locale) {
        this.locale = `locale-${locale}`;
      }
      if (tag) {
        this.tagFilter = tag;
      }
    }
  }

  syncUrlParams() {
    const params = new URLSearchParams();

    if (this.searchQuery) {
      params.set("q", this.searchQuery);
    } else {
      if (this.tagFilter) {
        params.set("tag", this.tagFilter);
      }
      if (this.locale && this.locale !== DEFAULT_LOCALE) {
        params.set("locale", this.locale.replace("locale-", ""));
      }
    }

    const newUrl = params.toString()
      ? `${window.location.pathname}?${params}`
      : window.location.pathname;

    window.history.replaceState(null, "", newUrl);
  }

  updateFilter(filter) {
    this.resetSearch();
    this.locale = DEFAULT_LOCALE;
    this.tagFilter = filter;
    this.syncUrlParams();
    this.resetPageAndFetch();
  }

  updateSearchQuery(query) {
    if (this.searchQuery === query) {
      return;
    }

    this.searchQuery = query;
    this.tagFilter = null;
    this.locale = query ? this.allLocale : DEFAULT_LOCALE;
    this.syncUrlParams();
    this.resetPageAndFetch();
  }

  updateLocale(locale) {
    this.locale = locale;
    this.tagFilter = null;
    this.resetSearch();
    this.syncUrlParams();
    this.resetPageAndFetch();
  }

  resetSearch() {
    this.searchQuery = "";
    this.inputText = "";
  }

  resetPageAndFetch() {
    this.currentPage = 1;
    this.topicResults = [];
    this.hasMoreResults = false;
    this.maxResults = false;
    this.getSiteList();
  }

  createSrcset(thumbnails) {
    return thumbnails
      .map((thumbnail) => `${thumbnail.url} ${thumbnail.width}w`)
      .join(", ");
  }

  createBannerImage(thumbnails) {
    const srcset = this.createSrcset(thumbnails);
    const sizes = "(max-width: 500px) 400px, (max-width: 600px) 800px, 1024px";
    const src = thumbnails[0].url; // default

    return { srcset, sizes, src };
  }

  parseResults(results) {
    return results.topics.map((topic) => ({
      ...topic,
      bannerImage: topic.thumbnails
        ? this.createBannerImage(topic.thumbnails)
        : null,
    }));
  }

  get currentFilter() {
    const category = Category.findById(
      parseInt(this.siteSettings.discourse_discover_category, 10)
    );

    let searchString = `#${category?.slug}`;

    if (this.locale !== this.allLocale) {
      searchString += ` #${this.locale}`;
    }

    if (this.locale === DEFAULT_LOCALE) {
      // only use the additional tag filters for the English locale
      // because there aren't enough sites to populate the others yet
      if (this.tagFilter) {
        searchString += ` tags:${this.tagFilter}`;
      }
    }

    if (this.searchQuery) {
      searchString += ` ${this.searchQuery}`;
    }

    if (!this.searchQuery || !this.searchQuery.includes("order:")) {
      // use "order:featured" from the discourse-discover plugin as default sort
      // allows overriding order in search input
      searchString += ` order:featured`;
    }

    return `/search.json?q=${encodeURIComponent(searchString)}&page=${
      this.currentPage
    }`;
  }

  @action
  resetSearchAndFetch() {
    this.resetSearch();
    this.locale = DEFAULT_LOCALE;
    this.syncUrlParams();
    this.resetPageAndFetch();
  }

  @action
  getSiteList() {
    if (this.loading) {
      return;
    }

    if (this.currentPage > this.maxPage) {
      this.hasMoreResults = false;
      this.maxResults = true;
      return;
    }

    this.loading = true;

    ajax(this.currentFilter)
      .then((data) => {
        this.hasMoreResults = data.grouped_search_result.more_full_page_results;
        if (!data.topics) {
          return;
        }

        this.topicResults =
          this.currentPage > 1
            ? [...this.topicResults, ...this.parseResults(data)]
            : this.parseResults(data);
        if (this.hasMoreResults) {
          this.currentPage++;
        }
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        console.error("Error fetching sites:", error);
      })
      .finally(() => {
        this.loading = false;
      });
  }
}
