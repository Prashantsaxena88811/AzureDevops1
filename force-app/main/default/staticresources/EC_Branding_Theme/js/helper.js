
var processDatePickers;
var stopGen = 0

function processDOM() {
    clearTimeout(processDatePickers)  ///stop additional clicks from initiating more timers
    if (document.querySelectorAll(".cEC_OrderList .date-picker input").length > 0) {
        console.log(document.querySelectorAll(".cEC_OrderList .date-picker input")[0].innerHTML);
        stopGen = 1;
        document.querySelectorAll(".cEC_OrderList .date-picker input").forEach(function (el) {

        });
    }

    if (!stopGen) {
        processDatePickers = setTimeout(function () { processDOM() }, 500)
    }
}
if (document.readyState == 'complete') {
    processDOM();
} else {
    document.onreadystatechange = function () {
        if (document.readyState === "complete") {
            processDOM();
        }
    }
}