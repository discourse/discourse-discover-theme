import Component from "@glimmer/component";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import { i18n } from "discourse-i18n";
import { htmlSafe } from "@ember/template";

export default class HubPromoMobile extends Component {
  @service site;
  @service capabilities;

  get deviceBadge() {
    if (this.capabilities.isIOS) {
      return settings.theme_uploads.ios;
    } else if (this.capabilities.isAndroid) {
      return settings.theme_uploads.android;
    }
  }

  <template>
    {{#if this.site.mobileView}}
      <div class="app-store-links">
        <a href={{this.deviceUrl}}>
          <img
            alt={{i18n (themePrefix "hub_promo.specific")}}
            src={{this.deviceBadge}}
          />
        </a>
      </div>
    {{/if}}
  </template>
}
