import hideApplicationSidebar from "discourse/helpers/hide-application-sidebar";
import HomeList from "../components/home-list";
import NavigationList from "../components/navigation-list";
import SearchFilter from "../components/search-filter";

const CustomHomepage = <template>
  {{hideApplicationSidebar}}
  <div class="discover-homepage">
    <SearchFilter />
    <div class="discover-homepage__directory">
      <NavigationList />
      <HomeList />
    </div>
  </div>
</template>;

export default CustomHomepage;
