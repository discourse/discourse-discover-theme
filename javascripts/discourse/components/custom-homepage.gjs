import Component from "@glimmer/component";
import { service } from "@ember/service";
import hideApplicationSidebar from "discourse/helpers/hide-application-sidebar";
import i18n from "discourse-common/helpers/i18n";
import Blobs from "../components/blobs";
import HomeList from "../components/home-list";
import NavigationList from "../components/navigation-list";
import SearchFilter from "../components/search-filter";

export default class CustomHomepage extends Component {
  @service homepageFilter;

  <template>
    <div class="discover-homepage">
      <Blobs />
      <SearchFilter />
      <div class="discover-homepage__directory">
        <NavigationList />
        <HomeList />
        {{#unless this.homepageFilter.loading}}
          <div class="add-your-site">
            <h3>
              {{i18n (themePrefix "footer.add_message")}}
              <a
                href="https://meta.discourse.org/t/introducing-discourse-discover/295223"
              >
                {{i18n (themePrefix "footer.add_link")}}
              </a>
            </h3>
          </div>
        {{/unless}}
      </div>
    </div>

    {{hideApplicationSidebar}}
  </template>
}
