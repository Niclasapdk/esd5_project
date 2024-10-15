document.addEventListener('DOMContentLoaded', function () {

    callbacks.cart.add.push(...TSOFT_APPS.cart.callback.add);
    callbacks.cart.load.push(...TSOFT_APPS.cart.callback.load);
    callbacks.cart.delete.push(...TSOFT_APPS.cart.callback.delete);
    callbacks.cart.deleteAll.push(...TSOFT_APPS.cart.callback.deleteAll);
    callbacks.cart.update.push(...TSOFT_APPS.cart.callback.update);
    callbacks.cart.updateAll.push(...TSOFT_APPS.cart.callback.updateAll);
  
    callbacks.order.address.push(...TSOFT_APPS.order.address.callback);
    callbacks.order.payment.push(...TSOFT_APPS.order.payment.callback);
    callbacks.order.paymentMethod.change.push(...TSOFT_APPS.paymentMethods.callback.change);

    callbacks.customerOrder.cancel.push(...TSOFT_APPS.order.cancel.callback);
    callbacks.customerOrder.return.push(...TSOFT_APPS.order.return.callback);

    callbacks.customer.login.push(...TSOFT_APPS.page.tracking.login.callback);
    callbacks.customer.sign.push(...TSOFT_APPS.page.tracking.sign.callback);
  
    callbacks.product.quickView.open.push(...TSOFT_APPS.product.quickView.callback.open);
    callbacks.product.wishList.remove.push(...TSOFT_APPS.product.wishList.callback.delete);
    callbacks.product.wishList.add.push(...TSOFT_APPS.product.wishList.callback.add);
    callbacks.product.dynamicLoader.push(...TSOFT_APPS.product.dynamicLoader);
  
  });

var TSOFT_APPS_callbackTry = true;
function TSOFT_APPS_addOrderCallback() {
  if (!TSOFT_APPS_callbackTry){
    return;
  }
  if (typeof callbacks?.order?.approve !== 'undefined') {
    const orderApproveCallback = (approveOrderData) => {
      if (TSOFT_APPS.order.approve.callback.length > 0) {
        TSOFT_APPS.order.approve.callback.forEach(call => {
          if (typeof call === "function") {
            try {
              call(JSON.parse(approveOrderData.orderData));
            } catch (e) {
              console.log("Page order approve callback error: ", e.message)
            }
          }
        })
      }
    }
    callbacks.order.approve.push(orderApproveCallback);
  } else {
    TSOFT_APPS_addOrderCallback()
  }
  setTimeout(() => {
    TSOFT_APPS_callbackTry = false;
  },1500);
}
  document.addEventListener('DOMContentLoaded', async function () {
  
    await TSOFT_APPS.get.basket();
    await TSOFT_APPS.get.cart.load();
  
    switch (PAGE_TYPE) {
      case 'other':
  
        TSOFT_APPS.page.other.callback.forEach(call => {
          if (typeof call === "function") {
            try {
              call();
            } catch (e) {
              console.log("Page other callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.page.other.callback.push = function (func) {
          if (typeof func === 'function') {
            try {
              func();
            }
            catch (e) {
              console.log("Page other callback error: ", e.message)
            }
            return Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
      case 'home':
  
        TSOFT_APPS.page.home.callback.forEach(call => {
          if (typeof call === "function") {
            try {
              call(PRODUCT_DATA);
            } catch (e) {
              console.log("Page home callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.page.home.callback.push = function (func) {
          if (typeof func === 'function') {
            try {
              func(PRODUCT_DATA);
            }
            catch (e) {
              console.log("Page home callback error: ", e.message)
            }
            return Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
      case 'category':
  
        TSOFT_APPS.page.category.callback.forEach(call => {
          if (typeof call === "function") {
            try {
              call(CATEGORY_DATA, PRODUCT_DATA);
            } catch (e) {
              console.log("Page category callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.page.category.callback.push = function (func) {
          if (typeof func === 'function') {
            try {
              func(CATEGORY_DATA, PRODUCT_DATA);
            }
            catch (e) {
              console.log("Page category callback error: ", e.message)
            }
            Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
      case 'product':
  
        TSOFT_APPS.product.detail.callback.forEach(call => {
          if (typeof call === "function") {
            try {
              call(PRODUCT_DATA);
            } catch (e) {
              console.log("Page product detail callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.product.detail.callback.push = function (func) {
          if (typeof func === 'function') {
            try {
              func(PRODUCT_DATA);
            }
            catch (e) {
              console.log("Page product detail callback error: ", e.message)
            }
            Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
      case 'cart':
  
        TSOFT_APPS.page.cart.callback.forEach(async call => {
          if (typeof call === "function") {
            try {
              call(await TSOFT_APPS.get.result.basket, await TSOFT_APPS.get.result.cart.load);
            } catch (e) {
              console.log("Page cart callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.page.cart.callback.push = async function (func) {
          if (typeof func === 'function') {
            try {
              func(await TSOFT_APPS.get.result.basket, await TSOFT_APPS.get.result.cart.load);
            }
            catch (e) {
              console.log("Page cart callback error: ", e.message)
            }
            Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
      case 'search':
  
        const searchWord = document.getElementById("search-word").value;
  
        TSOFT_APPS.page.search.callback.forEach(call => {
          if (typeof call === "function") {
            try {
              call(searchWord, PRODUCT_DATA);
            } catch (e) {
              console.log("Page search callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.page.search.callback.push = function (func) {
          if (typeof func === 'function') {
            try {
              func(searchWord, PRODUCT_DATA);
            }
            catch (e) {
              console.log("Page search callback error: ", e.message)
            }
            Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
      case "memberConfirmation":
  
        TSOFT_APPS.page.member.confirmation.callback.forEach(async call => {
          if (typeof call === "function") {
            try {
              call(MEMBER_INFO);
            } catch (e) {
              console.log("Page member confirmation callback error: ", e.message)
            }
          }
        })
  
        TSOFT_APPS.page.member.confirmation.callback.push = function (func) {
          if (typeof func === 'function') {
            try {
              func(MEMBER_INFO);
            }
            catch (e) {
              console.log("Page member confirmation callback error: ", e.message)
            }
            Array.prototype.push.apply(this, arguments);
          }
        }
  
        break;
    }
  
    TSOFT_APPS.page.tracking.login.callback.push = function (func) {
      if (typeof func === 'function') {
        callbacks.customer.login.push(func)
        return Array.prototype.push.apply(this, arguments);
      }
    }
  
    TSOFT_APPS.page.tracking.sign.callback.push = function (func) {
      if (typeof func === 'function') {
        callbacks.customer.sign.push(func)
        return Array.prototype.push.apply(this, arguments);
      }
    }
  
    TSOFT_APPS.order.address.callback.push = function (func) {
      if (typeof func === 'function') {
        callbacks.order.address.push(func)
        return Array.prototype.push.apply(this, arguments);
      }
    }
  
    TSOFT_APPS.order.payment.callback.push = function (func) {
      if (typeof func === 'function') {
        callbacks.order.payment.push(func)
        return Array.prototype.push.apply(this, arguments);
      }
    }
  
    TSOFT_APPS.order.approve.callback.push = function (func) {
      if (typeof func === 'function') {
        callbacks.order.approve.push(func)
        return Array.prototype.push.apply(this, arguments);
      }
    }
  });
  