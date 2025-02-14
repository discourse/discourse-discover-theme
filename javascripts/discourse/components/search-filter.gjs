import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { debounce } from "@ember/runloop";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import HubPromoDesktop from "../components/hub-promo-desktop";

const DEBOUNCE_VALUE = 300;

export default class NavigationList extends Component {
  @service store;
  @service siteSettings;
  @service homepageFilter;

  @tracked topics;
  @tracked inputText = "";

  @action
  updateSearchQuery(event) {
    if (event.target.value.length > 0 && event.target.value.length <= 2) {
      return;
    }
    debounce(this, this.applySearch, event.target.value, DEBOUNCE_VALUE);
  }

  applySearch(value) {
    this.homepageFilter.updateSearchQuery(value);
  }

  <template>
    <div class="homepage-filter-banner">
      <div class="homepage-filter-banner__content">
        <h1>Discover your next community</h1>
        <input
          type="text"
          id="filter"
          placeholder={{i18n (themePrefix "search.placeholder")}}
          oninput={{this.updateSearchQuery}}
          value={{this.homepageFilter.inputText}}
        />
        <HubPromoDesktop />
      </div>
    </div>
  </template>
}
