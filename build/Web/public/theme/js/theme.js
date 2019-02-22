;(function($) {
    "use strict";
    
    
    /*----------------------------------------------------*/
    /*  Menu scroll js
    /*----------------------------------------------------*/
    var nav_offset_top = $('.main_menu_area').offset().top + 100;
    function stickyHeader() {
		if ($('.main_menu_area').length) {
			var strickyScrollPos = nav_offset_top;
			if($(window).scrollTop() > strickyScrollPos) {
				$('.main_menu_area').removeClass('fadeIn animated');
				$('.main_menu_area').addClass('stricky-fixed fadeInDown animated')
			}
			else if($(window).scrollTop() <= strickyScrollPos) {
				$('.main_menu_area').removeClass('stricky-fixed fadeInDown animated');
				$('.main_menu_area').addClass('slideIn animated')
			}
		}
	}
    
    // instance of fuction while Window Scroll event
	$(window).on('scroll', function () {	
		stickyHeader()
	})
    
    
    $('.main_menu_area .nav.navbar-nav li a[href^="#"]:not([href="#"])').on('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top - 70
        }, 1500);
        event.preventDefault();
    });
    
    $('.click_btn').on('click', function(){
        $(".dropdown.submenu").toggleClass("open");
    });
    
    
    /*----------------------------------------------------*/
    /*  Home Slider2 js
    /*----------------------------------------------------*/
    function home_slider2(){
        if ( $('#main_slider').length ){
            $("#main_slider").revolution({
                sliderType:"fullscreen",
                sliderLayout:"fullwidth",
                dottedOverlay:"none",
                disableProgressBar:"on",
                delay:12000,
                navigation: {
                    keyboardNavigation:"off",
                    keyboard_direction: "horizontal",
                    mouseScrollNavigation:"off",
                    mouseScrollReverse:"default",
                    onHoverStop:"off",
                    touch:{
                        touchenabled:"on"
                    },
                    arrows: {
                        style:"Gyges",
                        enable:false,
                    }
                },
                responsiveLevels:[1920,1199,991,767,480],
                visibilityLevels:[1920,1199,991,767,480],
                gridwidth:[1140,970,900,767,480],
                gridheight:[800,700,600,580,580],
                spinner:"on",
                stopLoop:"off",
                shuffle:"off",
                hideThumbsOnMobile:"on",
                hideSliderAtLimit:0,
                hideCaptionAtLimit:0,
                hideAllCaptionAtLilmit:0,
                debugMode:false,
                fallbacks: {
                    simplifyAll:"off",
                    nextSlideOnWindowFocus:"off",
                    disableFocusListener:true,
                },
                lazyType:"none",
                parallax: {
                    type:"mouse",
                    origo:"slidercenter",
                    speed:2000,
                    levels:[2,3,4,5,6,7,12,16,10,50],
                },
            });
        }
    }
    home_slider2();  
    
    /*----------------------------------------------------*/
    /*  Testimonial Slider
    /*----------------------------------------------------*/
    function home_mobile_slider(){
        if ( $('.slider_moblie, .feature_mobile_slider, .clients_slider').length ){
            $('.slider_moblie, .feature_mobile_slider, .clients_slider').owlCarousel({
                loop:true,
                margin:0,
                items: 1,
                nav:false,
                autoplay: true,
                smartSpeed: 1500,
            })
        }
    }
    home_mobile_slider();
    
    /*----------------------------------------------------*/
    /*  Screenshot Slider
    /*----------------------------------------------------*/
    function screenshot_slider(){
        if ( $('.screenshot_slider').length ){
            $('.screenshot_slider').owlCarousel({
                loop:true,
                margin: 30,
                items: 5,
                nav:false,
                autoplay: false,
                smartSpeed: 1500,
                responsiveClass: true,
                center: true,
                responsive: {
                    0: {
                        items: 1,
                    },
                    600: {
                        items: 2,
                    },
                    940: {
                        items: 3,
                    },
                    1300: {
                        items: 4,
                        stagePadding: 0,
                    },
                    1570: {
                        items: 5,
                        stagePadding: 0,
                    },
                    1670: {
                        items: 5,
                        stagePadding: 50,
                    },
                    1850: {
                        items: 5,
                        stagePadding: 150,
                    }
                }
            })
        }
    }
    screenshot_slider();
    
    /*----------------------------------------------------*/
    /*  Screenshot Slider
    /*----------------------------------------------------*/
    function expert_slider(){
        if ( $('.expert_slider').length ){
            $('.expert_slider').owlCarousel({
                loop:true,
                margin: 30,
                items: 4,
                nav:false,
                autoplay: true,
                smartSpeed: 1500,
                responsiveClass: true,
                responsive: {
                    0: {
                        items: 1,
                    },
                    480: {
                        items: 2,
                    },
                    700: {
                        items: 3,
                    },
                    991: {
                        items: 4,
                    }
                }
            })
        }
    }
    expert_slider();
    
    /*----------------------------------------------------*/
    /*  Sponsors Slider
    /*----------------------------------------------------*/
    function sponsors_slider(){
        if ( $('.sponsor_slider').length ){
            $('.sponsor_slider').owlCarousel({
                loop:true,
                margin: 0,
                items: 4,
                nav:false,
                autoplay: true,
                smartSpeed: 1500,
                responsiveClass: true,
                responsive: {
                    0: {
                        items: 1,
                    },
                    360: {
                        items: 2,
                    },
                    550: {
                        items: 3,
                    },
                    767: {
                        items: 4,
                    }
                }
            })
        }
    }
    sponsors_slider();

    
    /*----------------------------------------------------*/
    /*  Sponsors Slider
    /*----------------------------------------------------*/
    $(".3d_screenshot_inner").flipster({
        scrollwheel: false,
        spacing: -0.7,
        style: 'coverflow',
        loop: true,
        start: 'center',
        touch: true,
    });
    


    $(document).ready(function(){
        $(".benefits_right .video_row iframe").css({'height':($(".benefits_left").height()+'px')});
        $(".benefits_right .video_row iframe").css({'width':($(".benefits_left").width()+'px')});
    });
//    $(document).ready(function(){
//        $(".shap_mobile_screen").css({'height':($(".screenshot_slider .item").height()+'px')});
//        $(".shap_mobile_screen").css({'width':($(".screenshot_slider .item").width()+'px')});
//    });
    
   
    
    /*----------------------------------------------------*/
    /*  Google map js
    /*----------------------------------------------------*/
    
    if ( $('#mapBox').length ){
        var $lat = $('#mapBox').data('lat');
        var $lon = $('#mapBox').data('lon');
        var $zoom = $('#mapBox').data('zoom');
//        var $marker = $('#mapBox').data('marker');
//        var $info = $('#mapBox').data('info');
//        var $markerLat = $('#mapBox').data('mlat');
//        var $markerLon = $('#mapBox').data('mlon');
        var map = new GMaps({
            el: '#mapBox',
            lat: $lat,
            lng: $lon,
            scrollwheel: false,
            scaleControl: true,
            streetViewControl: false,
            panControl: true,
            disableDoubleClickZoom: true,
            mapTypeControl: false,
            zoom: $zoom,
                styles: [
    {
        "featureType": "landscape",
        "stylers": [
            {
                "hue": "#00dd00"
            }
        ]
    },
    {
        "featureType": "road",
        "stylers": [
            {
                "hue": "#dd0000"
            }
        ]
    },
    {
        "featureType": "water",
        "stylers": [
            {
                "hue": "#000040"
            }
        ]
    },
    {
        "featureType": "poi.park",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    },
    {
        "featureType": "road.arterial",
        "stylers": [
            {
                "hue": "#ffff00"
            }
        ]
    },
    {
        "featureType": "road.local",
        "stylers": [
            {
                "visibility": "off"
            }
        ]
    }
]
            });
        
//            map.addMarker({
//                lat: $markerLat,
//                lng: $markerLon,
//                icon: $marker,    
//                infoWindow: {
//                  content: $info
//                }
//            })
        }
    
})(jQuery)
