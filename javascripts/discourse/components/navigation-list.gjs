import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import { bind } from "discourse-common/utils/decorators";
import FaqButton from "../components/faq-button";
import ComboBox from "select-kit/components/combo-box";
import { action } from "@ember/object";
import { hash } from "@ember/helper";

export default class NavigationList extends Component {
  @service store;
  @service siteSettings;
  @service homepageFilter;

  @tracked topics;

  @bind
  updateFilter(tagName) {
    this.homepageFilter.updateFilter(tagName);
  }

  @action
  updateLocale(locale) {
    this.homepageFilter.locale = locale;
    localStorage.setItem("DiscoverLocale", locale);
    this.homepageFilter.resetPageAndFetch();
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

  get localeList() {
    const locales = settings.locale_filter.map((locale) => ({
      tagName: locale.tag[0],
      label: locale.text,
    }));

    return locales;
  }

  <template>
    <div class="discover-navigation-list-wrapper">
      <ul class="discover-navigation-list">
        {{#each this.navItems as |item|}}
          <li>
            <button
              type="button"
              data-tag-name={{item.tagName}}
              {{on "click" (fn this.updateFilter item.tagName)}}
              class="discover-navigation-list__item plausible-event-name=Category+Button+Click plausible-event-category={{or
                  item.tagName
                  'all'
                }}
                {{if item.isActive '--active'}}"
            >
              {{#if item.icon}}
                {{dIcon item.icon}}
              {{/if}}
              {{item.label}}
            </button>
          </li>
        {{/each}}
        <li class="locale-switcher__list-item">
          <ComboBox
            class="locale-switcher discover-navigation-list__item"
            @valueProperty="tagName"
            @content={{this.localeList}}
            @value={{this.homepageFilter.locale}}
            @onChange={{this.updateLocale}}
            @options={{hash icon="globe"}}
          />
        </li>
        <li class="add-your-site">
          <FaqButton />
        </li>
      </ul>
    </div>
  </template>
}
