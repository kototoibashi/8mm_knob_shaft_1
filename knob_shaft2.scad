// --- Parameters ---
$fn = 120;
KNOB_DIAMETER = 60;
KNOB_HEIGHT = 30;
KNOB_SQUEEZE = 5;
SHAFT_DIAMETER = 8.2;
GRIP_FINS = 12*5;
GRIP_FINS2 = 6;

// 新規パラメータ：材料節約と構造剛性のバランス
WALL_INNER = 8.0;
WALL_THICKNESS = 4.0; // 外壁および上面の厚み
BOSS_DIAMETER = SHAFT_DIAMETER + 6; // シャフト周囲の肉厚

// --- Modules ---

module shaft_hole() {
    // 貫通しない設計を維持しつつ、マージンを確保
    translate([0, 0, -1])
        cylinder(d = SHAFT_DIAMETER, h = KNOB_HEIGHT + 1);
}

module knob_main() {
    difference() {
        // 1. 外部形状の定義（ポジティブ形状）
        union() {
            cylinder(d = SHAFT_DIAMETER * 2, h = KNOB_SQUEEZE);
            translate([0, 0, KNOB_SQUEEZE]) 
                cylinder(d2 = KNOB_DIAMETER, d1 = KNOB_DIAMETER - 4, h = 5);
            translate([0, 0, KNOB_SQUEEZE + 5]) 
                cylinder(d = KNOB_DIAMETER, h = KNOB_HEIGHT - KNOB_SQUEEZE - 10);
            translate([0, 0, KNOB_HEIGHT - 5]) 
                cylinder(d1 = KNOB_DIAMETER, d2 = KNOB_DIAMETER - 4, h = 5);
            
        }

        // 2. グリップ用ディテールの削り込み
        for (i = [0 : GRIP_FINS - 1]) {
            rotate([0, 0, i * (360 / GRIP_FINS)])
                translate([KNOB_DIAMETER / 2, 0, -1])
                    cylinder(d = 2, h = KNOB_HEIGHT + 2, $fn = 12);
        }

        for (i = [0 : GRIP_FINS2 - 1]) {
            rotate([0, 0, (i + 0.5) * (360 / GRIP_FINS2)])
                translate([KNOB_DIAMETER / 2 + 5 , 0, -1])
                    cylinder(d = 30, h = KNOB_HEIGHT + 2, $fn = 60);
        }

        // 3. 中空化処理（シェル構造）
        // 上面（KNOB_HEIGHT）からWALL_THICKNESS分を残して内部をえぐる
        translate([0, 0, -1])
            cylinder(d1 = KNOB_DIAMETER - WALL_INNER * 2 ,d2 = KNOB_DIAMETER - WALL_INNER * 2, h = KNOB_HEIGHT + 1);

    }

    // 5. 補強構造の追加（削除された肉の代わりに必要な剛性を付与）
    intersection() {
        // 外形の内側に限定
        cylinder(d = KNOB_DIAMETER - 0.1, h = KNOB_HEIGHT - 0.1);
        
        union() {
            // シャフトボス：シャフト穴周辺の肉付け
            cylinder(d = BOSS_DIAMETER, h = KNOB_HEIGHT);
            
            // 放射状リブ：トルクを外殻に伝えるための構造
            for (i = [0 : 6]) {
                rotate([0, 0, i * (360/6)]){
                    translate([0, -WALL_THICKNESS / 2, KNOB_SQUEEZE])
                        cube([(KNOB_DIAMETER - WALL_INNER) / 2, WALL_THICKNESS, KNOB_HEIGHT - WALL_THICKNESS]);
                    translate([-13, 17.5, KNOB_SQUEEZE])
                        cube([(KNOB_DIAMETER - WALL_INNER) / 2, WALL_THICKNESS, KNOB_HEIGHT - WALL_THICKNESS]);
                }
            }
        }
    }
}

// 実行
module knob_body(){
    difference() {
    knob_main();
            // 4. シャフト穴とネジ穴
            shaft_hole();

            for (i = [0 : 4 - 1]) {
                translate([0, 0, KNOB_SQUEEZE/2])
                    rotate([0, 90, i * 90])
                        cylinder(d = 3.8, h = KNOB_DIAMETER + 1);
            }
    }
}

module circular_text(label, radius, size, start_angle = 90, letter_spacing = 15) {
    chars = str(label);
    len = len(chars);
    
    for (i = [0 : len - 1]) {
        // 各文字の角度計算：開始角度から時計回りに配置
        angle = start_angle - (i * letter_spacing);
        
        rotate([0, 0, angle])
            translate([radius, 0, 0])
                rotate([0, 0, -90]) // 文字自体を直立させるための補正
                    text(
                        text = chars[i],
                        size = size,
                        font = "Liberation Sans:style=Bold",
                        halign = "center",
                        valign = "center"
                    );
    }
}

module knob_with_curved_text(label = "MAIN VALVE") {
    difference() {
        knob_body();

        // 上面への円周刻印
        translate([0, 0, KNOB_HEIGHT - 2]) {
            linear_extrude(height = 2) {
                circular_text(
                    label = label,
                    radius = KNOB_DIAMETER / 2 - 10, // 外周から少し内側に配置
                    size = 2,
                    start_angle = 120,               // 配置の開始位置（度）
                    letter_spacing = 8              // 文字の間隔（度）
                );
            }
        }
    }
}

// 実行
knob_with_curved_text("<<<OPEN  MAIN VALVE CLOSE>>>");