import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { service } from "@ember/service";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import bodyClass from "discourse/helpers/body-class";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";

export default class HomeList extends Component {
  @service store;
  @service siteSettings;
  @service homepageFilter;

  parseJSON = (str) => {
    try {
      return JSON.parse(str);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error parsing JSON:", error);
      return {};
    }
  };

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{bodyClass "discover-home"}}

    <ul
      class="discover-list"
      {{didInsert this.homepageFilter.getSiteList}}
      {{didUpdate
        this.homepageFilter.getSiteList
        this.homepageFilter.tagFilter
      }}
    >
      {{#if this.homepageFilter.topicResults}}
        {{#each this.homepageFilter.topicResults as |topic|}}
          <li class="discover-list__item">
            <a
              href={{topic.featured_link}}
              target="_blank"
              rel="noopener noreferrer"
              class="discover-list__item-link"
            >
              <img class="discover-list__item-banner" src={{topic.image_url}} />
              <div class="discover-list__item-content">
                <h2>
                  <img
                    class="discover-list__item-logo"
                    src={{topic.image_url}}
                  />
                  {{topic.title}}
                </h2>
                <div class="discover-list__item-meta">
                  {{#if topic.topics_30_days}}
                    <span>{{dIcon "comments"}}{{topic.topics_30_days}}</span>
                  {{/if}}
                  {{#if topic.users_30_days}}
                    <span>{{dIcon "user"}}
                      {{topic.users_30_days}}</span>
                  {{/if}}
                </div>
                <p class="discover-list__item-excerpt">
                  lorem ipsum dolor sit amit consequtor adspicio elit lorem
                  ipsum dolor sit amit consequtor adspicio elit lorem ipsum
                  dolor sit amit consequtor adspicio elit lorem ipsum dolor sit
                  amit consequtor adspicio elit
                  {{topic.excerpt}}
                </p>
              </div>
            </a>
          </li>
        {{/each}}
      {{else}}
        <ConditionalLoadingSpinner @condition={{this.homepageFilter.loading}}>
          <li class="no-results">
            {{i18n (themePrefix "search.no_results")}}
            {{#if this.homepageFilter.searchQuery}}
              —
              <a {{on "click" this.homepageFilter.resetFilter}}>
                {{i18n (themePrefix "search.remove_filter")}}
              </a>{{/if}}
          </li>
        </ConditionalLoadingSpinner>
      {{/if}}
    </ul>
  </template>
}
