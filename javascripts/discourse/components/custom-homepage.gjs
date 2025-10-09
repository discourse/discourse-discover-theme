import hideApplicationSidebar from "discourse/helpers/hide-application-sidebar";
import Blobs from "../components/blobs";
import HomeList from "../components/home-list";
import NavigationList from "../components/navigation-list";
import SearchFilter from "../components/search-filter";

const CustomHomepage = <template>
  {{hideApplicationSidebar}}
  <div class="discover-homepage">
    <Blobs />
    <SearchFilter />
    <div class="discover-homepage__directory">
      <NavigationList />
      <HomeList />
    </div>
  </div>
</template>;

export default CustomHomepage;
