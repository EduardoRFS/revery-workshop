open Revery;
open Revery.UI;
open Revery.UI.Components;

let render = (elem) => {
	let init = app => {
			let createOptions =
					WindowCreateOptions.create(
							~width=1024,
							~height=800,
							(),
					);
			let win = App.createWindow(~createOptions, app, "FlappyRevery");

			let _ = UI.start(win, elem);
			();
	};

	App.start(init);
};
