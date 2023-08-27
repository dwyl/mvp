// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Item id of the destination id to switch
let itemId_to;

let Hooks = {}
Hooks.Items = {
  mounted() {
    const hook = this

    this.el.addEventListener("highlight", e => {
      hook.pushEventTo("#items", "highlight", {id: e.detail.id})
      // console.log('highlight', e.detail.id)
    })

    this.el.addEventListener("remove-highlight", e => {
      hook.pushEventTo("#items", "removeHighlight", {id: e.detail.id})
      // console.log('remove-highlight', e.detail.id)
    })

    this.el.addEventListener("dragoverItem", e => {
      // console.log("dragoverItem", e.detail)
      const currentItemId = e.detail.currentItem.id
      const selectedItemId = e.detail.selectedItemId
      if( currentItemId != selectedItemId) {
        hook.pushEventTo("#items", "dragoverItem", {currentItemId: currentItemId, selectedItemId: selectedItemId})
        itemId_to = e.detail.currentItem.dataset.id
      }
    })

    this.el.addEventListener("update-indexes", e => {
      const item_id = e.detail.fromItemId 
      const list_ids = get_list_item_cids()
      console.log("update-indexes", e.detail, "list: ", list_ids)
      // Check if both "from" and "to" are defined
      if(item_id && itemId_to && item_id != itemId_to) {
        hook.pushEventTo("#items", "updateIndexes", 
          {seq: list_ids})
      }
      
      itemId_to = null;
    })
  }
}

/**
 * `get_list_item_ids/0` retrieves the full `list` of visible `items` form the DOM
 * and returns a String containing the IDs as a space-separated list e.g: "1 2 3 42 71 93"
 * This is used to determine the `position` of the `item` that has been moved.
 */
function get_list_item_cids() {
  console.log("invoke get_list_item_ids")
  const lis = document.querySelectorAll("label[phx-value-cid]");
  return Object.values(lis).map(li => {
    return li.attributes["phx-value-cid"].nodeValue
  }).join(",")
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  dom:{
        onBeforeElUpdated(from, to) {
          if (from._x_dataStack) {
            window.Alpine.clone(from, to)
          }
        }
  },
  params: {
    _csrf_token: csrfToken,
    hours_offset_fromUTC: -new Date().getTimezoneOffset()/60
  }
})


// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Drag and drop highlight handlers
window.addEventListener("phx:highlight", (e) => {
  document.querySelectorAll("[data-highlight]").forEach(el => {
    if(el.id == e.detail.id) {
        liveSocket.execJS(el, el.getAttribute("data-highlight"))
    }
  })
})

window.addEventListener("phx:remove-highlight", (e) => {
  document.querySelectorAll("[data-highlight]").forEach(el => {
    if(el.id == e.detail.id) {
        liveSocket.execJS(el, el.getAttribute("data-remove-highlight"))
    }
  })
})

window.addEventListener("phx:dragover-item", (e) => {
  console.log("phx:dragover-item", e.detail)
  const selectedItem = document.querySelector(`#${e.detail.selected_item_id}`)
  const currentItem = document.querySelector(`#${e.detail.current_item_id}`)

  const items = document.querySelector('#items')
  const listItems = [...document.querySelectorAll('.item')]

  if(listItems.indexOf(selectedItem) < listItems.indexOf(currentItem)){
    items.insertBefore(selectedItem, currentItem.nextSibling)
  }

  if(listItems.indexOf(selectedItem) > listItems.indexOf(currentItem)){
    items.insertBefore(selectedItem, currentItem)
  }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

