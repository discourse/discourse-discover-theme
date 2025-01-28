import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service, { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";
import i18n from "discourse-common/helpers/i18n";

const ALL_LOCALE = i18n(themePrefix("navigation.all"));
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

  updateFilter(filter) {
    this.resetSearch();

    this.tagFilter = filter;
    this.resetPageAndFetch();
  }

  updateSearchQuery(query) {
    if (this.searchQuery !== query) {
      this.searchQuery = query;
      this.tagFilter = null;
      this.locale = ALL_LOCALE;
      this.resetPageAndFetch();
    }

    if (this.searchQuery === "") {
      // reset locale to default when clearing search
      this.locale = DEFAULT_LOCALE;
    }
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

    if (this.locale !== ALL_LOCALE) {
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
