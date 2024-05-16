import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service, { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";

export default class HomepageFilter extends Service {
  @service siteSettings;

  @tracked tagFilter = null;
  @tracked topicResults = [];
  @tracked searchQuery = null;
  @tracked inputText = "";
  @tracked loading = false;
  @tracked hasMoreResults = false;
  @tracked currentPage = 1;

  updateFilter(filter) {
    this.resetSearch();

    this.tagFilter = filter;
    this.resetPageAndFetch();
  }

  updateSearchQuery(query) {
    if (this.searchQuery !== query) {
      this.searchQuery = query;
      this.resetPageAndFetch();
    }
  }

  resetSearch() {
    this.searchQuery = null;
    this.inputText = "";
  }

  resetPageAndFetch() {
    this.currentPage = 1;
    this.topicResults = [];
    this.hasMoreResults = false;
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
    let initialResultSortOption = -1;

    if (!this.tagFilter && !this.searchQuery && this.currentPage === 1) {
      // randomize initial results sort order so that homepage has some variety
      // only for the first page of results on the homepage
      initialResultSortOption = Math.ceil(Math.random() * 4);
      // 1. sort by active user count
      // 2. sort by topic count
      // 3. sort alphabetically
      // 4. default order
    }

    return results.topics
      .map((topic) => ({
        ...topic,
        bannerImage: topic.thumbnails
          ? this.createBannerImage(topic.thumbnails)
          : null,
      }))
      .sort((a, b) => {
        if (initialResultSortOption === 1) {
          if (a.active_users_30_days > b.active_users_30_days) {
            return -1;
          }
        }

        if (initialResultSortOption === 2) {
          if (a.topics_30_days > b.topics_30_days) {
            return -1;
          }
        }

        if (initialResultSortOption === 3) {
          return a.title.localeCompare(b.title);
        }

        return 0;
      });
  }

  get currentFilter() {
    const category = Category.findById(
      parseInt(this.siteSettings.discourse_discover_category, 10)
    );

    let searchString = `#${category?.slug}`;
    if (this.tagFilter) {
      searchString += ` tags:${this.tagFilter}`;
    }
    if (this.searchQuery) {
      searchString += ` ${this.searchQuery}`;
    }

    return `/search.json?q=${encodeURIComponent(
      searchString
    )}%20order%3Afeatured&page=${this.currentPage}`;
    // uses "order:featured" from the discourse-discover plugin
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
