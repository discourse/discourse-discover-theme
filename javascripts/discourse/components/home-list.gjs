import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import dIcon from "discourse-common/helpers/d-icon";
// import i18n from "discourse-common/helpers/i18n";

export default class HomeList extends Component {
  @service store;
  @service siteSettings;
  @tracked topics;

  constructor() {
    super(...arguments);

    const count = 50; // TODO: turn this into a loadmore component
    const route = `c/${this.siteSettings.discourse_discover_category}.json?status=listed`;

    ajax(route).then((data) => {
      let results = data.topic_list.topics;
      results = results.filter((t) => t.featured_link !== null);

      results.forEach((topic) => {
        topic.thumb800 = topic.thumbnails?.filter(
          (th) => th.max_width === 800
        )[0];
      });
      this.topics = results.slice(0, count);
    });
  }

  <template>
    <div class="home-list">
      {{#each this.topics as |topic|}}
        <div class="home-list-item">
          {{#if topic.thumb800}}
            <a
              href={{topic.featured_link}}
              target="_blank"
              rel="noopener noreferrer"
              class="home-list-item__image"
            >
              <img
                src={{topic.thumb800.url}}
                alt={{topic.title}}
                style="max-width: 400px; height: auto;"
              />
            </a>
          {{else}}
            <div class="home-list-item__no-image"></div>
          {{/if}}
          <h2>
            <a
              href={{topic.featured_link}}
              target="_blank"
              rel="noopener noreferrer"
            >
              {{topic.title}}
            </a>
          </h2>
          <div class="home-list-item__metadata">
            {{#if topic.users_30_days}}
              <span class="home-list-item__users">
                {{dIcon "user"}}
                {{topic.users_30_days}}+ users
              </span>
            {{/if}}
            {{#if topic.topics_30_days}}
              <span class="home-list-item__topics">
                {{dIcon "cog"}}
                {{topic.topics_30_days}}+ topics
              </span>
            {{/if}}
          </div>
        </div>
      {{/each}}
    </div>
  </template>
}
