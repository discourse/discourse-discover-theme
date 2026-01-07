import { withPluginApi } from "discourse/lib/plugin-api";
import HeaderNav from "../components/header-nav";

export default {
  name: "add-custom-nav",

  initialize() {
    withPluginApi((api) => {
      api.headerButtons.add("header-nav", HeaderNav);
    });
  },
};
