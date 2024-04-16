import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service, { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";

export default class HomepageFilter extends Service {
  @service siteSettings;

  @tracked tagFilter = null;
  @tracked topicResults = [];
  @tracked searchQuery = "";
  @tracked inputText = "";
  @tracked loading = false;
  @tracked hasMoreResults = false;
  @tracked currentPage = 1;

  updateFilter(filter) {
    if (this.tagFilter !== filter) {
      this.tagFilter = filter;
      this.resetPageAndFetch();
    }
  }

  updateSearchQuery(query) {
    if (this.searchQuery !== query) {
      this.searchQuery = query;
      this.resetPageAndFetch();
    }
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
    const sizes = "(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw";
    const src = thumbnails[0].url;

    return { srcset, sizes, src };
  }

  parseResults(results) {
    return results.topics.map((topic) => ({
      ...topic,
      discover_entry: topic.discover_entry
        ? {
            ...topic.discover_entry,
            extra: topic.discover_entry.extra
              ? JSON.parse(topic.discover_entry.extra)
              : {},
          }
        : {},
      bannerImage: topic.thumbnails
        ? this.createBannerImage(topic.thumbnails)
        : null,
    }));
  }

  get currentFilter() {
    const category = Category.findById(
      parseInt(this.siteSettings.discourse_discover_category, 10)
    );

    let searchString = `#${category.slug}`;
    if (this.tagFilter) {
      searchString += ` tags:${this.tagFilter}`;
    }
    if (this.searchQuery) {
      searchString += ` ${this.searchQuery}`;
    }

    return `/search.json?q=${encodeURIComponent(searchString)}&page=${
      this.currentPage
    }`;
  }

  @action
  resetSearch() {
    this.searchQuery = "";
    this.inputText = "";
    this.resetPageAndFetch();
  }

  @action
  getSiteList() {
    this.loading = true;

    ajax(this.currentFilter)
      .then((data) => {
        this.hasMoreResults = data.grouped_search_result.more_full_page_results;
        if (!data.topics) {
          this.topicResults = [];
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
