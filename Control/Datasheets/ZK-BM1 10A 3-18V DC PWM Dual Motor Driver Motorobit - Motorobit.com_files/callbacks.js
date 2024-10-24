window.PERSONALIZATION = window.PERSONALIZATION || {};
window.ON_PAGE_READY = window.ON_PAGE_READY || [];
window.DEFAULT_READY = window.DEFAULT_READY || [];

window['callbacks'] = {
    customer: {
        login: [],
        sign: [],
        other: [],
        subscribe: [],
    },
    cart: {
        update: [],
        updateAll: [],
        delete: [],
        deleteAll: [],
        load: [],
        add: [],
        error: [],
    },
    order: {
        address: [],
        payment: [],
        paymentMethod: {
            change: [],
        },
        approve: [],
    },
    product: {
        quickView: {
            open: [],
            close: [],
        },
        favourite: {
            add: [],
            remove: [],
        },
        wishList: {
            add: [],
            remove: [],
            load: [],
        },
        stockAlarm: [],
        priceAlarm: [],
        dynamicLoader: [],
        personalizationUpload: [],
        click: [],
    },
    customerOrder: {
        productLoad: [],
        returnLoad: [],
        return: [],
        cancel: []
    },
}