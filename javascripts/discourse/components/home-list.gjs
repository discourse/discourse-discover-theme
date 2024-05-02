import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import ConditionalLoadingSpinner from "discourse/components/conditional-loading-spinner";
import LoadMore from "discourse/components/load-more";
import bodyClass from "discourse/helpers/body-class";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import DTooltip from "float-kit/components/d-tooltip";

export default class HomeList extends Component {
  @service store;
  @service siteSettings;
  @service homepageFilter;
  @service currentUser;

  parseJSON = (str) => {
    try {
      return JSON.parse(str);
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error parsing JSON:", error);
      return {};
    }
  };

  roundStat(num) {
    if (num < 10) {
      return num;
    } else if (num < 1000) {
      return Math.ceil(num / 10) * 10;
    } else {
      return Math.ceil(num / 100) * 100;
    }
  }

  @action
  loadMore() {
    if (this.homepageFilter.hasMoreResults) {
      this.homepageFilter.getSiteList();
    }
  }

  @action
  checkImageBackgroundColor(event) {
    const imageElement = event.target;

    const canvas = document.createElement("canvas");
    canvas.width = imageElement.naturalWidth;
    canvas.height = imageElement.naturalHeight;
    const context = canvas.getContext("2d");

    try {
      context.drawImage(imageElement, 0, 0, canvas.width, canvas.height);
      const data = context.getImageData(0, 0, canvas.width, canvas.height).data;

      let weightedSum = 0;
      let alphaSum = 0;
      for (let i = 0; i < data.length; i += 4) {
        let alpha = data[i + 3];
        let avg = (data[i] + data[i + 1] + data[i + 2]) / 3;
        weightedSum += avg * (alpha / 255);
        alphaSum += alpha / 255;
      }

      // if no alpha, adding a background color has no effect
      const averageColorValue = alphaSum > 0 ? weightedSum / alphaSum : 0;

      if (averageColorValue >= 240) {
        // if the image is mostly white, it probably needs a dark background
        imageElement.style.backgroundColor = "#333";
      }
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error("Error checking logo background:", error);
    }
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    {{bodyClass "discover-home"}}

    <ul class="discover-list" {{didInsert this.homepageFilter.getSiteList}}>
      {{#if this.homepageFilter.topicResults}}
        {{#each this.homepageFilter.topicResults as |topic|}}
          <li class="discover-list__item">
            <a
              href={{topic.featured_link}}
              target="_blank"
              rel="noopener noreferrer"
              class="discover-list__item-link"
            >
              <div class="discover-list__item-banner">
                <img
                  srcset={{topic.bannerImage.srcset}}
                  src={{topic.bannerImage.src}}
                  sizes={{topic.bannerImage.sizes}}
                />
                {{#unless topic.bannerImage.src}}
                  <div class="no-image">{{dIcon "fab-discourse"}}</div>
                {{/unless}}
              </div>
              {{#if topic.discover_entry_logo_url}}
                <div class="discover-list__item-logo">
                  <img
                    src={{topic.discover_entry_logo_url}}
                    alt="topic logo"
                    crossOrigin="Anonymous"
                    {{on "load" this.checkImageBackgroundColor}}
                  />
                </div>
              {{/if}}
              <h2>
                <span>{{topic.title}}</span>
              </h2>
              <div class="discover-list__item-meta">
                {{#if topic.users_30_days}}
                  <span>
                    <DTooltip @identifier="active-topics">
                      <:trigger>
                        {{dIcon "user-friends"}}
                        {{this.roundStat topic.users_30_days}}
                      </:trigger>
                      <:content>
                        {{i18n (themePrefix "tooltip.users")}}
                      </:content>
                    </DTooltip>
                  </span>
                {{/if}}
                {{#if topic.topics_30_days}}
                  <span>
                    <DTooltip @identifier="active-topics">
                      <:trigger>
                        {{dIcon "comments"}}
                        {{this.roundStat topic.topics_30_days}}
                      </:trigger>
                      <:content>
                        {{i18n (themePrefix "tooltip.posts")}}
                      </:content>
                    </DTooltip>
                  </span>
                {{/if}}
              </div>
              <p class="discover-list__item-excerpt">
                {{htmlSafe topic.excerpt}}
              </p>
            </a>
            {{#if this.currentUser.admin}}
              <a
                class="admin-link"
                href="/t/{{topic.id}}"
                target="_blank"
                rel="noopener noreferrer"
              >{{dIcon "cog"}}</a>
            {{/if}}
          </li>
        {{/each}}
        <LoadMore @selector=".discover-list__item" @action={{this.loadMore}} />
      {{else}}
        <ConditionalLoadingSpinner @condition={{this.homepageFilter.loading}}>
          <li class="no-results">
            {{i18n (themePrefix "search.no_results")}}
            {{#if this.homepageFilter.searchQuery}}
              —
              <a {{on "click" this.homepageFilter.resetSearch}}>
                {{i18n (themePrefix "search.remove_filter")}}
              </a>{{/if}}
          </li>
          {{bodyClass "--no-results"}}
        </ConditionalLoadingSpinner>
      {{/if}}
    </ul>
  </template>
}
