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

  get filter() {
    if (this.searchQuery) {
      const category = Category.findById(
        parseInt(this.siteSettings.discourse_discover_category, 10)
      );

      const tagFilter = this.tagFilter ? ` tags%3A${this.tagFilter}` : "";

      return `/search.json?q=${this.searchQuery} %23${category.slug}${tagFilter}`;
    } else {
      return this.tagFilter
        ? `/tags/c/${this.siteSettings.discourse_discover_category}/${this.tagFilter}.json`
        : `c/${this.siteSettings.discourse_discover_category}.json`;
    }
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
        if (this.searchQuery) {
          if (data.topics?.length) {
            this.topicResults = data.topics?.slice(0, count);
          } else {
            this.topicResults = [];
          }
        } else {
          let results = data.topic_list.topics.filter(
            (t) => t.featured_link !== null
          );

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
            }))
            .slice(0, count);

          this.topicResults = results;
        }

        this.loading = false;
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        console.error("Error fetching sites:", error);
      });
  }
}
