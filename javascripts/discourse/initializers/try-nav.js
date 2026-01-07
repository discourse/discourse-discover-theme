import { withPluginApi } from "discourse/lib/plugin-api";
import TryHeaderNav from "../components/try-header-nav";

export default {
  name: "add-custom-nav",

  initialize() {
    withPluginApi("1.29.0", (api) => {
      api.headerButtons.add("try-header-nav", TryHeaderNav);
    });
  },
};
