import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";

export default class LearnMoreModal extends Component {
  @service router;

  @action
  customClose() {
    this.args.closeModal();
    this.removeQueryParam("faq");
  }

  @action
  removeQueryParam(param) {
    let queryParams = { ...this.router.currentRoute.queryParams };
    delete queryParams[param];
    this.router.transitionTo("/", { queryParams });
  }

  <template>
    <DModal
      @title={{i18n (themePrefix "faq_modal.title")}}
      @closeModal={{this.customClose}}
      class="learn-more-modal"
    >
      <:body>
        <article class="modal-content">
          <section class="faq-item">
            {{htmlSafe (i18n (themePrefix "faq_modal.intro"))}}
          </section>
          <section class="faq-item">
            <h2 tabindex="0">
              {{i18n (themePrefix "faq_modal.how.title")}}
            </h2>
            {{htmlSafe (i18n (themePrefix "faq_modal.how.body"))}}
          </section>
          <section class="faq-item">
            <h2>
              {{i18n (themePrefix "faq_modal.what.title")}}
            </h2>
            {{htmlSafe (i18n (themePrefix "faq_modal.what.body"))}}
          </section>
          <section class="faq-item">
            <h2>{{i18n (themePrefix "faq_modal.category.title")}}</h2>
            {{htmlSafe (i18n (themePrefix "faq_modal.category.body"))}}
          </section>
          <section class="faq-item">
            <h2>{{i18n (themePrefix "faq_modal.contact.title")}}</h2>
            {{htmlSafe (i18n (themePrefix "faq_modal.contact.body"))}}
          </section>
        </article>
      </:body>
    </DModal>
  </template>
}
