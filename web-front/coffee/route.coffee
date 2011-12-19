class AppRouter extends Backbone.Router
    templateDoc: JST['info/doc']
    
    initialize: =>
        @isLogin = false
        @nabaztagCollection = new NabaztagCollection()
        @applicationCollection = new ApplicationCollection()
        @info = new InfoView()
        $('#info').html($(@info.render().el))
        $('.showLogin').hide()
        $('.showLogout').hide()
    
    setIsLogin: (isLogin) =>
        @isLogin = isLogin
        if isLogin
            $('.showLogin').hide()
            $('.showLogout').show()
        else
            $('.showLogout').hide()
            $('.showLogin').show()
            
    
    routes:
        "onLogin": "onLogin"
        "logout": "logout"
        "nabaztag/action/:id": "nabaztagAction"
        "nabaztag/list": "nabaztagList"
        "nabaztag/add": "nabaztagAdd"
        "nabaztag/:mac/appinstall/:apikey": "nabaztagInstallApp"
        "nabaztag/:mac/appinstall/:apikey/:uuid": "nabaztagInstallApp"
        "applications": "applicationList"
        "nab2nabs": "nab2nabs"
        "doc": "doc"
        "*actions": "defaultRoute"
    

    defaultRoute: ( actions ) =>
        console?.log( actions )        
        if(@isLogin)
            @navigate("nabaztag/list", true)
        else
            $('#content').html(@templateDoc())
    
    doc: =>
        $('#content').html(@templateDoc())

    onLogin: =>
        console?.log("onLogin")
        @setIsLogin(true)
        @navigate("nabaztag/list", true)
        
    logout: =>
        console?.log("logout")
        $.Storage.remove("token")
        @setIsLogin(false)
        @navigate("home", true)
        
    nabaztagList: =>
        console?.log("nabaztagList: ", @nabaztagCollection)
        nabaztagCollectionView = new NabaztagCollectionView({model: @nabaztagCollection})
        $('#content').html($(nabaztagCollectionView.el))
        
    nabaztagAction: (id)=>
        @nabaztagCollection.getAndRun(id, (nab)=>
            console?.log("nab",nab)
            nabaztagActionView = new NabaztagActionView({model: nab})
            $('#content').html($(nabaztagActionView.render().el))
        )

    nabaztagAdd: =>
        console?.log("nabaztagAdd")
        nabaztagAddView = new NabaztagAddView()
        $('#content').html($(nabaztagAddView.render().el))
        
    nabaztagInstallApp: (mac, apikey, uuid) =>
        console?.log("nabaztagInstallApp")
        @nabaztagCollection.getAndRun(mac, (nab)=>
            @applicationCollection.getAndRun(apikey, (app)=>
                console?.log("nab",nab)
                console?.log("app",app)
                applicationConfigView = new ApplicationConfigView({model: nab, application: app, uuid: uuid})
                $('#content').html($(applicationConfigView.render().el))
            )   
        )     
        
    applicationList: =>
        console?.log("applicationList")
        applicationCollectionView = new ApplicationCollectionView({model: @applicationCollection})
        $('#content').html($(applicationCollectionView.render().el))
    
    nab2nabs: =>
        console?.log("nab2nabs")
        nab2NabsView = new Nab2NabsView({model: @nabaztagCollection})
        $('#content').html($(nab2NabsView.render().el))

global = this

refreshCounter = =>
    $.getJSON('/admin/connected/infos')
    .success((result)=>
        $('#connected').html("[#{result.connected}]")
    )

$(document).ready(=>
    login = new LoginView()
    $('#login').html($(login.render().el))
    
    global.router = new AppRouter()
    refreshCounter()
    setInterval(refreshCounter, 15000)
    
    token = $.Storage.get("token");
    if token
        $.getJSON('user/info', {"token": token})
        .success(=>
            global.router.setIsLogin(true)
            global.router.nabaztagCollection.fetch()
        )
        .error(=>
            global.router.setIsLogin(false)
            global.router.navigate("login", true)
        )
        .complete(=>
            Backbone.history.start()
        )
    else
        global.router.setIsLogin(false)
        global.router.navigate("home", true)
        Backbone.history.start()
)
