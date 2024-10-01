/*// Sayfanın başlangıç başlığını saklamak için bir değişken
var originalTitle = document.title;

// Tarayıcı sekmesi değiştiğinde çalışacak olan olay dinleyicisi
document.addEventListener('visibilitychange', function() {
	if (document.visibilityState === 'hidden') {
		var message = "Bizi unutma";
		var emoji = "🤖";
		document.title = emoji + " " + message + " " + emoji;
	} else {
		document.title = originalTitle;
	}
});*/

function updateTime() {
	var d = new Date();
	var day = d.getDay();
	if ((day != 6) && (day != 0)) {
		var hours = 14 - d.getHours();
		if (hours < 0) {
			hours = 24 + hours;
		}
		var min = 59 - d.getMinutes();
		if ((min + '').length == 1) {
			min = '0' + min;
		}
		var sec = 59 - d.getSeconds();
		if ((sec + '').length == 1) {
			sec = '0' + sec;
		}

		if (hours < 15) {
			jQuery('#header-bar').html('<div class="timer-hour">'+ hours +'<span>&nbspsaat&nbsp</span></diV><div class="timer-minute">'+ min +'<span>&nbspdakika&nbsp</span></diV><!--:<div class="timer-second">'+ sec +'</diV>--> <span> içinde verilen siparişler BUGÜN KARGODA </span>');
		}
		else {
			//jQuery('.header-countdown').html(hours+':'+min+':'+sec +' saat içinde verilen siparişler yarın kargoda')
			jQuery('#header-bar').html('<span>Şimdi sipariş ver yarın kargoda</span>');
		}
	}
	else {
		jQuery('#header-bar').hide();
	}
}

// Sayfa yüklendiğinde zamanı güncelle
document.addEventListener("DOMContentLoaded", function() {
	updateTime();
	// Daha sonra her 1 dakikada bir zamanı güncelle
	setInterval(updateTime, 60000);
});

document.addEventListener("DOMContentLoaded", function () {
	// qty sınıfı altındaki input elementini seçin
	var inputElement = document.querySelector(".qty input[type='number']");

	// Input elementi var mı kontrol edin
	if (inputElement) {
		// Input değerini dinleyin
		inputElement.addEventListener("input", function () {
			var inputValue = parseInt(this.value, 10); // Girdiyi tamsayıya çevirin
			var maxLimit = parseInt(this.getAttribute("max"), 10); // max değeri alın

			if (inputValue > maxLimit) {
				this.value = maxLimit; // Değeri max değere eşitleyin
			}
		});
	}
});

function updateShippingInfo() {
	// Sepet toplamını CART_TOTAL değişkeninden alın (örnek olarak 909.58 TL).
	var cartPriceContainer = document.getElementById("cart-price-container");

	// HTML yapısının içeriğini alın
	var cartPriceText = cartPriceContainer.textContent;

	// İlgili metni ayıklayarak CART_TOTAL değerini alın
	var CART_TOTAL_2 = cartPriceText.trim().split("Genel Toplam")[1].trim().split(":")[1].trim();

	var sepetToplam = parseFloat(CART_TOTAL_2.replace("TL", "").replace(".", "").replace(",", ".").trim());


	// Ücretsiz kargo sınırını tanımlayın (örnek olarak 1000 TL).
	var ucretsizKargoSiniri = 1500;

	// Kargo ücreti hesaplaması yapın.
	var kargoUcreti = ucretsizKargoSiniri - sepetToplam;

	// Hesaplanan kargo ücretini sayfada gösterin.
	if (sepetToplam < 1500 ) {
		document.getElementById("remaining-amount").innerHTML  ="SEPETİNİZE <strong> " + kargoUcreti.toFixed(2) + "</strong> TL DAHA ÜRÜN EKLEYİN KARGONUZ ÜCRETSİZ OLSUN!";
	} else {
		document.getElementById("remaining-amount").innerHTML = "TEBRİKLER SİPARİŞ TOPLAMINIZ 1500 TL'Yİ GEÇTİĞİ İÇİN <strong>KARGO ÜCRETSİZ!</strong>";
	}
}

// Belirli aralıklarla sepeti güncelleyin (örneğin, her 1 saniyede bir).
setInterval(function() {
	// Mevcut sayfa URL'sini alın
	var currentPath = window.location.pathname;

	// Eğer sayfa URL'si "/sepet" ise updateShippingInfo() fonksiyonunu çağırın
	if (currentPath === "/sepet") {
		updateShippingInfo();
	}
}, 1000);

// Sayfa yüklendiğinde de başlangıçta kargo bilgisini güncelleyin
window.onload = function () {
	// Mevcut sayfa URL'sini alın
	var currentPath = window.location.pathname;

	// Eğer sayfa URL'si "/sepet" ise updateShippingInfo() fonksiyonunu çağırın
	if (currentPath === "/sepet") {
		updateShippingInfo();
	}
};

function updateShippingInfo2() {
	var cartPriceContainer = document.getElementById("header-cart");

	// HTML yapısının içeriğini alın
	var cartPriceText = cartPriceContainer.textContent;

	// İlgili metni ayıklayarak CART_TOTAL değerini alın
	var cartTotal = cartPriceText.trim().split("Genel Toplam")[1].trim().split(":")[1].trim().split(" ")[0];
	var cartTotal2 = parseFloat(cartTotal.replace("TL", "").replace(".", "").replace(",", ".").trim());


	// Ücretsiz kargo sınırını tanımlayın (örnek olarak 1000 TL).
	var ucretsizKargoSiniri = 1500;

	// Kargo ücreti hesaplaması yapın.
	var kargoUcreti = ucretsizKargoSiniri - cartTotal2;
	
	// "header-cart" ID'sine sahip HTML elementini seçin
	var headerCartElement = document.getElementById("header-cart");

	if (!document.getElementById("remaining-amount2")) {
        // Burada yeni elementin oluşturulması ve eklenecek içeriği ekleyin
        var newElement = document.createElement("div");
        newElement.id = "free-shipping";
        newElement.className = "cart-block pr-2 pl-2";
        
        // Yeni div elementinin içeriği
        newElement.innerHTML = `
          <div class="free-shipping-content d-flex align-items-center">
            <div id="remaining-amount2" class="free-shipping-text mr-2">${cartTotal}</div>
            <div class="free-shipping-icon"><img src="https://dosya.motorobit.com/resim/shipping-fast-solid.png"></div>
          </div>
        `;

        // "header-cart" elementinin hemen sonrasına yeni div elementini ekleyin
        var headerCartElement = document.getElementById("header-cart");
        headerCartElement.parentNode.insertBefore(newElement, headerCartElement.nextSibling);
    }

	// Hesaplanan kargo ücretini sayfada gösterin.
	if (cartTotal2 < 1500 ) {
		document.getElementById("remaining-amount2").innerHTML  ="SEPETİNİZE <strong> " + kargoUcreti.toFixed(2) + "</strong> TL DAHA ÜRÜN EKLEYİN KARGONUZ ÜCRETSİZ OLSUN!";
	} else {
		document.getElementById("remaining-amount2").innerHTML = "TEBRİKLER SİPARİŞ TOPLAMINIZ 1500 TL'Yİ GEÇTİĞİ İÇİN <strong>KARGO ÜCRETSİZ!</strong>";
	}
}

// Belirli aralıklarla sepeti güncelleyin (örneğin, her 1 saniyede bir).
setInterval(function() {
	// "header-cart" ID'sine sahip HTML elementini seçin
    var headerCartElement = document.getElementById("header-cart");

    // Eğer "header-cart" elementi varsa, updateShippingInfo2 fonksiyonunu çağırın
    if (headerCartElement) {
		updateShippingInfo2();
	}
}, 1000);


window.onload = function () {
    // "header-cart" ID'sine sahip HTML elementini seçin
    var headerCartElement = document.getElementById("header-cart");

    // Eğer "header-cart" elementi varsa, updateShippingInfo2 fonksiyonunu çağırın
    if (headerCartElement) {
        updateShippingInfo2();
    }
};

