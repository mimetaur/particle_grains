// Engine_SimpleGrain
// sine grain with a gaussian envelope
// duration in ms, freq in hz
// by @mimetaur

Engine_SimpleGrain : CroneEngine {
	var hz = 440;
	var amp = 0.3;
	var dur = 100;
	var bell_width = 0.5;
	var pan = 0;

	var synthGroup;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		synthGroup = ParGroup.tail(context.xg);
		SynthDef(\SimpleGrain, {
			arg out, hz = hz, amp = amp, dur = dur, bell_width = bell_width, pan = pan;
			var dur_in_sec = dur * 0.001;
			var bell_width_scaled = bell_width.lincurve(0, 1.0, 0.001, 0.25, curve: -1, clip: 'minmax');
			var snd = SinOsc.ar(hz);
			var env = LFGauss.ar(duration: dur_in_sec, width: bell_width_scaled, loop: 0, doneAction: 2).range(0, amp);
			var sig = snd * env;
			Out.ar(out, Pan2.ar(sig, pan));
		}).add;

		this.addCommand("hz", "f", { arg msg;
			var val = msg[1];
			Synth(\SimpleGrain, [\out, context.out_b, \hz, val, \amp, amp, \dur, dur, \bell_width, bell_width, \pan, pan], target:synthGroup);
		});

		this.addCommand("dur", "f", { arg msg;
			dur = msg[1];
		});

		this.addCommand("amp", "f", { arg msg;
			amp = msg[1];
		});

		this.addCommand("bell_width", "f", { arg msg;
			bell_width = msg[1];
		});

		this.addCommand("pan", "f", { arg msg;
			pan = msg[1];
		});
	}
}