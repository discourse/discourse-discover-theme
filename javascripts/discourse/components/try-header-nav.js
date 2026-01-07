import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { cancel, later } from "@ember/runloop";

export default class TryHeaderNav extends Component {
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
}
