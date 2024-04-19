import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import { bind } from "discourse-common/utils/decorators";

export default class NavigationList extends Component {
  @service store;
  @service siteSettings;
  @service homepageFilter;

  @tracked topics;

  @bind
  updateFilter(tagName) {
    this.homepageFilter.updateFilter(tagName);
  }

  get navItems() {
    const allItem = {
      tagName: null,
      label: i18n(themePrefix("navigation.all")),
      isActive: !this.homepageFilter.tagFilter,
    };

    const tagItems = settings.homepage_filter.map((object) => ({
      tagName: object.tag[0],
      label: object.button_text,
      icon: object.icon,
      isActive: object.tag[0] === this.homepageFilter.tagFilter,
    }));

    return [allItem, ...tagItems];
  }

  <template>
    {{! template-lint-disable no-invalid-interactive }}
    <div class="discover-navigation-list-wrapper">
      <ul class="discover-navigation-list">
        {{#each this.navItems as |item|}}
          <li
            data-tag-name={{item.tagName}}
            {{on "click" (fn this.updateFilter item.tagName)}}
            class="discover-navigation-list__item
              {{if item.isActive '--active'}}"
          >
            {{#if item.icon}}
              {{dIcon item.icon}}
            {{/if}}
            {{item.label}}
          </li>
        {{/each}}
      </ul>

      <div class="add-your-site">
        <h3>
          {{i18n (themePrefix "footer.add_message")}}
          <a
            href="https://meta.discourse.org/t/introducing-discourse-discover/295223"
          >
            {{i18n (themePrefix "footer.add_link")}}
          </a>
        </h3>
      </div>
    </div>
  </template>
}
