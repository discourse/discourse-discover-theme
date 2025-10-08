import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import bodyClass from "discourse/helpers/body-class";
import dIcon from "discourse/helpers/d-icon";
import { bind } from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";
import ComboBox from "select-kit/components/combo-box";
import FaqButton from "../components/faq-button";

export default class NavigationList extends Component {
  @service homepageFilter;

  @tracked topics;

  @bind
  updateFilter(tagName) {
    this.homepageFilter.updateFilter(tagName);
  }

  @action
  updateLocale(locale) {
    // when switching locale, we want to reset everything else
    this.homepageFilter.locale = locale;
    this.homepageFilter.tagFilter = null;
    this.homepageFilter.resetSearch();
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
        <li class="add-your-site">
          <FaqButton />
        </li>
      </ul>
    </div>
  </template>
}
