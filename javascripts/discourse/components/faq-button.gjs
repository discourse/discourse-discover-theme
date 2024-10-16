import Component from "@glimmer/component";
import { action } from "@ember/object";
import { scheduleOnce } from "@ember/runloop";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import i18n from "discourse-common/helpers/i18n";
import LearnMoreModal from "../components/modal/learn-more";

export default class NavigationList extends Component {
  @service modal;
  @service router;

  constructor() {
    super(...arguments);
    scheduleOnce("afterRender", this, this.checkForModalTrigger);
  }

  @action
  showLearnMoreModal() {
    this.modal.show(LearnMoreModal);
  }

  @action
  checkForModalTrigger() {
    const queryParams = this.router.currentRoute.queryParams;
    if (queryParams.hasOwnProperty("faq")) {
      this.showLearnMoreModal();
    }
  }

  <template>
    <DButton
      @action={{this.showLearnMoreModal}}
      @translatedLabel={{i18n (themePrefix "footer.learn_more")}}
      class="btn-transparent"
      @icon="question-circle"
    />
  </template>
}
