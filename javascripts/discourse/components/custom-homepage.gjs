import Component from "@glimmer/component";
import { service } from "@ember/service";
import hideApplicationSidebar from "discourse/helpers/hide-application-sidebar";
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
      </div>
    </div>

    {{hideApplicationSidebar}}
  </template>
}
