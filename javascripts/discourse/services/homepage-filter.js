import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import Service, { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import Category from "discourse/models/category";

const count = 50; // TODO: turn this into a loadmore component

export default class HomepageFilter extends Service {
  @service siteSettings;

  @tracked tagFilter = null;
  @tracked topicResults = [];
  @tracked searchQuery = "";
  @tracked inputText = "";
  @tracked loading = true;

  updateFilter(filter) {
    if (this.tagFilter !== filter) {
      this.tagFilter = filter;
    }
  }

  createSrcset(thumbnails) {
    return thumbnails
      .map((thumbnail) => `${thumbnail.url} ${thumbnail.width}w`)
      .join(", ");
  }

  createBannerImage(thumbnails) {
    const srcset = this.createSrcset(thumbnails);
    const sizes = "(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"; // This can be adjusted or dynamically generated if necessary
    const src = thumbnails[0].url; // Fallback to the first thumbnail's URL

    return { srcset, sizes, src };
  }

  get filter() {
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

    return `/search.json?q=${encodeURIComponent(searchString)}`;
  }

  @action
  resetFilter() {
    this.searchQuery = "";
    this.inputText = "";
    this.loading = true;
    this.getSiteList();
  }

  @action
  getSiteList() {
    this.loading = true;
    ajax(this.filter)
      .then((data) => {
        if (!data.topics) {
          return (this.topicResults = []);
        }
        let results = data.topics.filter((t) => t.featured_link !== null);

        // parse "extra"
        results = results
          .map((topic) => ({
            ...topic,
            discover_entry: topic.discover_entry
              ? {
                  ...topic.discover_entry,
                  extra: topic.discover_entry.extra
                    ? this.parseJSON(topic.discover_entry.extra)
                    : {},
                }
              : {},
            bannerImage: topic.thumbnails
              ? this.createBannerImage(topic.thumbnails)
              : { srcset: "", sizes: "", src: "" },
          }))
          .slice(0, count);

        this.topicResults = results;
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
