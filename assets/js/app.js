// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Drag and drop highlight handlers
window.addEventListener("phx:highlight", (e) => {
  document.querySelectorAll("[data-highlight]").forEach(el => {
    if(el.id == e.detail.id) {
        live_socket.execJS(el, el.getAttribute("data-highlight"))
    }
  })
})

// Item ID of the destination during drag over in the DOM
let item_id_destination;

let Hooks = {}
Hooks.Items = {
  mounted() {
    const hook = this

    this.el.addEventListener("highlight", e => {
      hook.pushEventTo("#items", "highlight", {id: e.detail.id})
      // console.log('highlight', e.detail.id)
    })

    this.el.addEventListener("remove-highlight", e => {
      hook.pushEventTo("#items", "remove_highlight", {id: e.detail.id})
      // console.log('remove-highlight', e.detail.id)
    })

    this.el.addEventListener("dragover_item", e => {
      // console.log("dragover_item", e.detail)
      const current_item_id = e.detail.current_item.id
      const selected_item_id = e.detail.selected_item_id
      if( current_item_id != selected_item_id) {
        hook.pushEventTo("#items", "dragover_item", {current_item_id: current_item_id, selected_item_id: selected_item_id})
        item_id_destination = e.detail.current_item.dataset.id
      }
    })

    this.el.addEventListener("update_indexes", e => {
      const item_id = e.detail.fromItemId 
      const list_ids = get_list_item_cids()
      console.log("update_indexes", e.detail, "list: ", list_ids)
      // Check if both "from" and "to" are defined
      if(item_id && item_id_destination && item_id != item_id_destination) {
        hook.pushEventTo("#items", "update_list_seq", 
          {seq: list_ids})
      }
      
      item_id_destination = null;
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

window.addEventListener("phx:remove-highlight", (e) => {
  document.querySelectorAll("[data-highlight]").forEach(el => {
    if(el.id == e.detail.id) {
        live_socket.execJS(el, el.getAttribute("data-remove-highlight"))
    }
  })
})

window.addEventListener("phx:dragover-item", (e) => {
  console.log("phx:dragover-item", e.detail)
  const selected_item = document.querySelector(`#${e.detail.selected_item_id}`)
  const current_item = document.querySelector(`#${e.detail.current_item_id}`)

  const items = document.querySelector('#items')
  const list_items = [...document.querySelectorAll('.item')]

  if(list_items.indexOf(selected_item) < list_items.indexOf(current_item)){
    items.insertBefore(selected_item, current_item.nextSibling)
  }

  if(list_items.indexOf(selected_item) > list_items.indexOf(current_item)){
    items.insertBefore(selected_item, current_item)
  }
})

// live_socket related setup:

let csrf_token = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let live_socket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  dom:{
        onBeforeElUpdated(from, to) {
          if (from._x_dataStack) {
            window.Alpine.clone(from, to)
          }
        }
  },
  params: {
    _csrf_token: csrf_token,
    hours_offset_fromUTC: -new Date().getTimezoneOffset()/60
  }
})

// connect if there are any LiveViews on the page
live_socket.connect()

// expose live_socket on window for web console debug logs and latency simulation:
// >> live_socket.enableDebug()
// >> live_socket.enableLatencySim(1000)  // enabled for duration of browser session
// >> live_socket.disableLatencySim()
window.live_socket = live_socket

