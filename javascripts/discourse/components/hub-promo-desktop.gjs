import Component from "@glimmer/component";
import { service } from "@ember/service";
import { or } from "truth-helpers";
import { i18n } from "discourse-i18n";
import { htmlSafe } from "@ember/template";

export default class HubPromoDesktop extends Component {
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
    {{#if this.site.desktopView}}
      <div class="homepage-filter-banner__hub-links">
        {{htmlSafe
          (i18n
            (themePrefix "hub_promo.general")
            android=settings.android_url
            ios=settings.ios_url
          )
        }}
      </div>
    {{/if}}
  </template>
}
