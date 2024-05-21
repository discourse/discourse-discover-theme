import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import i18n from "discourse-common/helpers/i18n";
import LearnMoreModal from "../components/modal/learn-more";

export default class NavigationList extends Component {
  @service modal;

  @action
  showLearnMoreModal() {
    this.modal.show(LearnMoreModal);
  }

  <template>
    <DButton
      @action={{this.showLearnMoreModal}}
      @translatedLabel={{i18n (themePrefix "footer.learn_more")}}
      @class="btn-transparent"
    />
  </template>
}
