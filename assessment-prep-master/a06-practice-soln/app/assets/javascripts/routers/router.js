PostApp.Routers.Router = Backbone.Router.extend({
  initialize: function (options) {
    this.$rootEl = options.$rootEl;
    this.collection = options.posts;
  },

  routes: {
    "": "index",
    "posts/new": "new",
    "posts/:id": "show",
    "posts/:id/edit": "edit"
  },

  edit: function (id) {
    var post = this.collection.getOrFetch(id);

    var formView = new PostApp.Views.PostForm({
      model: post,
      collection: this.collection
    });

    this._swapView(formView);
  },

  index: function () {
    this.collection.fetch();

    var indexView = new PostApp.Views.PostsIndex({
      collection: this.collection
    });

    this._swapView(indexView);
  },

  new: function () {
    var newPost = new PostApp.Models.Post();

    var formView = new PostApp.Views.PostForm({
      collection: this.collection,
      model: newPost
    });

    this._swapView(formView);
  },

  show: function (id) {
    var post = this.collection.getOrFetch(id);
    var formView = new PostApp.Views.PostShow({ model: post });
    this._swapView(formView);
  },

  _swapView: function (view) {
    this._currentView && this._currentView.remove();
    this._currentView = view;
    this.$rootEl.html(view.render().$el);
  }
});
