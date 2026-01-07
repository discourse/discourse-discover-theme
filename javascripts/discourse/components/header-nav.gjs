import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { cancel, later } from "@ember/runloop";
import { eq, or } from "truth-helpers";
import dIcon from "discourse/helpers/d-icon";

export default class HeaderNav extends Component {
  @tracked currentSubmenuIndex = null;
  @tracked hideSubmenuTimer = null;
  @tracked isSubmenuHovered = false;
  @tracked isTopLevelMenuItemHovered = false;

  @action
  hideSubmenu() {
    this.scheduleSubmenuHide();
  }

  @action
  topLevelMenuItemMouseEnter(index) {
    this.isTopLevelMenuItemHovered = true;

    if (this.hideSubmenuTimer) {
      cancel(this.hideSubmenuTimer);
      this.hideSubmenuTimer = null;
    }

    if (this.currentSubmenuIndex !== index) {
      this.scheduleSubmenuHide();
    }
    this.showSubmenuInstantly(index);
  }

  @action
  topLevelMenuItemMouseLeave() {
    this.isTopLevelMenuItemHovered = false;
    this.scheduleSubmenuHide();
  }

  @action
  showSubmenuInstantly(index) {
    if (this.hideSubmenuTimer) {
      cancel(this.hideSubmenuTimer);
      this.hideSubmenuTimer = null;
    }
    this.currentSubmenuIndex = index;
  }

  @action
  scheduleSubmenuHide() {
    this.hideSubmenuTimer = later(() => {
      if (!this.isSubmenuHovered) {
        this.currentSubmenuIndex = null;
      }
    }, 300);
  }

  @action
  submenuMouseEnter() {
    this.isSubmenuHovered = true;
    if (this.hideSubmenuTimer) {
      cancel(this.hideSubmenuTimer);
    }
  }

  @action
  submenuMouseLeave() {
    this.isSubmenuHovered = false;
    if (!this.isTopLevelMenuItemHovered) {
      this.scheduleSubmenuHide();
    }
  }

  <template>
    {{#unless (or @minimized @mobileView)}}
      <nav class="navigation" aria-label="Main menu">
        <div class="navigation-list-wrapper">
          <ul class="navigation-list">
            <li
              class="navigation-list__item"
              {{on "mouseenter" (fn this.topLevelMenuItemMouseEnter 0)}}
              {{on "mouseleave" this.topLevelMenuItemMouseLeave}}
            >
              <a
                href="#"
                class="navigation-list__link navigation-list__link--has-child"
              >
                About
                {{dIcon "chevron-down" class="navigation-list__chevron"}}
              </a>
              <ul
                class="navigation-list__sub-item-list js-dropdown-list
                  {{if (eq this.currentSubmenuIndex 0) 'is-active'}}"
                aria-hidden="true"
                aria-label="Resources submenu"
              >
                <li class="navigation-list__sub-item">
                  <a href="https://discourse.org/about">
                    What is Discourse?
                  </a>
                </li>
                <li class="navigation-list__sub-item">
                  <a href="https://discourse.org/team">
                    Who we are
                  </a>
                </li>
                <li class="navigation-list__sub-item">
                  <a href="https://discourse.org/customers">
                    Customers
                  </a>
                </li>
                <li class="navigation-list__sub-item">
                  <a href="https://discourse.org/wall-of-love">
                    Wall of love
                  </a>
                </li>
                <li class="navigation-list__sub-item">
                  <a href="https://discourse.org/partners">
                    Partners
                  </a>
                </li>
                <li class="navigation-list__sub-item">
                  <a href="https://discourse.org/jobs">
                    Careers
                  </a>
                </li>
              </ul>
            </li>
            <li class="navigation-list__item">
              <a
                href="https://discourse.org/features"
                class="navigation-list__link"
              >
                Features
              </a>
            </li>
            <li class="navigation-list__item">
              <a
                href="https://discover.discourse.com"
                class="navigation-list__link is-active"
              >
                Discover
              </a>
            </li>
            <li class="navigation-list__item">
              <a
                href="https://discourse.org/enterprise"
                class="navigation-list__link"
              >
                Enterprise
              </a>
            </li>
            <li class="navigation-list__item">
              <a
                class="navigation-list__link"
                href="https://discourse.org/pricing"
                ga-on="click"
                ga-event-category="main-nav"
                ga-event-label="pricing"
                ga-event-action="click"
              >
                Pricing
              </a>
            </li>
            <li class="navigation-list__item">
              <a href="#" class="navigation-list__link">
                Resources
              </a>
            </li>
          </ul>
        </div>
      </nav>
    {{/unless}}
  </template>
}
