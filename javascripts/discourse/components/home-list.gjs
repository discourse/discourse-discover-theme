import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
// import i18n from "discourse-common/helpers/i18n";

export default class HomeList extends Component {
  @service store;
  @service siteSettings;
  @tracked topics;

  constructor() {
    super(...arguments);

    const count = 50; // TODO: turn this into a loadmore component
    const filter = `c/${this.siteSettings.discourse_discover_category}.json`;

    ajax(filter).then((data) => {
      let results = data.topic_list.topics;
      results = results.filter((t) => t.featured_link !== null);
      this.topics = results.slice(0, count);
    });
  }

  <template>
    <div class="home-list">
      {{#each this.topics as |topic|}}
        <div class="home-list-item">
          <h2>
            <a href={{topic.featured_link}} target="_blank">
              {{topic.title}}
            </a>
          </h2>
          {{log topic}}
        </div>
      {{/each}}
    </div>
  </template>
}
