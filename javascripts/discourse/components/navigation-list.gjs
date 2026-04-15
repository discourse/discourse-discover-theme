import Component from "@glimmer/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import bodyClass from "discourse/helpers/body-class";
import dIcon from "discourse/helpers/d-icon";
import { bind } from "discourse/lib/decorators";
import ComboBox from "discourse/select-kit/components/combo-box";
import { or } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import FaqButton from "../components/faq-button";

const RECENTLY_ADDED_ORDER = "latest_topic";

export default class NavigationList extends Component {
  @service homepageFilter;

  @bind
  updateFilter(tagName) {
    this.homepageFilter.updateFilter(tagName);
  }

  @action
  updateLocale(locale) {
    this.homepageFilter.updateLocale(locale);
  }

  @action
  onItemClick(item) {
    if (item.orderBy) {
      this.homepageFilter.updateOrder(item.orderBy);
    } else {
      this.updateFilter(item.tagName);
    }
  }

  get navItems() {
    const allItem = {
      tagName: null,
      label: i18n(themePrefix("navigation.all")),
      isActive: !this.homepageFilter.tagFilter && !this.homepageFilter.orderBy,
    };

    const tagItems = settings.homepage_filter.map((object) => ({
      tagName: object.tag[0],
      label: object.button_text,
      icon: object.icon,
      isActive: object.tag[0] === this.homepageFilter.tagFilter,
    }));

    const recentlyAddedItem = {
      orderBy: RECENTLY_ADDED_ORDER,
      label: i18n(themePrefix("navigation.recently_added")),
      icon: "clock",
      isActive: this.homepageFilter.orderBy === RECENTLY_ADDED_ORDER,
    };

    return [allItem, ...tagItems, recentlyAddedItem];
  }

  get localeList() {
    const locales = settings.locale_filter.map((locale) => ({
      tagName: locale.tag[0],
      label: locale.text,
    }));

    return locales;
  }

  <template>
    {{bodyClass this.homepageFilter.locale}}
    <div class="discover-navigation-list-wrapper">
      <ul class="discover-navigation-list">
        <li class="locale-switcher__list-item">
          <ComboBox
            class="locale-switcher discover-navigation-list__item"
            @valueProperty="tagName"
            @content={{this.localeList}}
            @value={{this.homepageFilter.locale}}
            @onChange={{this.updateLocale}}
            @options={{hash icon="globe" autoFilterable=false}}
          />
        </li>
        {{#each this.navItems as |item|}}
          <li class="discover-navigation-list__filter-wrapper">
            <button
              type="button"
              data-tag-name={{item.tagName}}
              data-order={{item.orderBy}}
              {{on "click" (fn this.onItemClick item)}}
              class="discover-navigation-list__item plausible-event-name=Category+Button+Click plausible-event-category={{or
                  item.tagName
                  item.orderBy
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
        <li class="add-your-site">
          <FaqButton />
        </li>
      </ul>
    </div>
  </template>
}
