({
    doInit: function() {
        jQuery("document").ready(function() {
            $('body').on('click', '.date-pick', function() {
                $(this).toggleClass('show-dropdown');
                $('.date-pick-dropdown').slideToggle();
            });
            $('body').on('click', '.close-pickreport', function() {
                $('.date-pick').removeClass('show-dropdown');
                $('.date-pick-dropdown').slideUp();
            });
            $(document).mouseup(function(e) {
                var container = $('.date-pick');
                if (!container.is(e.target) && container.has(e.target).length === 0 ) {
                    $('.date-pick').removeClass('show-dropdown');
                    $('.date-pick-dropdown').slideUp();
                }
            });
            $('body').on('click', '.view-more-btn button', function() {
                $('.fixed-date-picklist').addClass('show-list');
                $('.date-pick').removeClass('show-dropdown');
                $('.date-pick-dropdown').slideUp();
                $('body').css('overflowY', 'hidden');
            });
            $('body').on('click', '.fixed-close-pickreport', function() {
                $('.fixed-date-picklist').removeClass('show-list');
                $('body').css('overflowY', 'auto');
            });
            $('body').on('click', '.report-toggle .material-icons', function() {
                $('.report-box').toggleClass('expanded');
                $('.report-box-bottom').slideToggle();
            });
            $('body').on('click', '.tile-box', function() {
                $('.tile-box').not(this).removeClass('expanded');
                $(this).toggleClass('expanded');
                $('.tile-lineitems').removeClass('collapsed');
                $(".mat-filter select").find('option:eq(0)').prop('selected', true);
                $(".mat-table .row-2").show();
                if ($('.tile-box').hasClass('expanded') && $(window).width() < 768) {
                    $('body').css('overflowY', 'hidden'); 
                } else {
                    $('body').css('overflowY', 'auto');
                }
            });
            $('body').on('click', '.close-table', function() {
                $('.tile-box').removeClass('expanded');
                $('body').css('overflowY', 'auto');
            });
            $('body').on('click', '.lineitem-toggle .material-icons', function() {
                $(this).closest('.tile-lineitems').toggleClass('collapsed');
            });
            $('body').on('click', '.print-box', function () {
                window.print();
            });
        });
    }
})