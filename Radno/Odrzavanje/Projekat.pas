unit Projekat;

{
  AquaCentar — AquaOdrzavanje Modul
  Upravljanje odrzavanjem vodenog sportskog centra

  Moduli:
    - Dashboard (pregled alarma i otvorenih naloga)
    - Merenja vode (pH, hlor, temperatura po bazenu)
    - Radni nalozi (otvaranje, pracenje, zatvaranje)
    - Oprema (evidencija i status)
    - Magacin (zalihe materijala)

  Vizuelni stil: AquaCentar tamna morska tema
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.IOUtils, System.Math, System.NetEncoding,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.TabControl, FMX.Layouts, FMX.StdCtrls, FMX.Edit,
  FMX.Controls.Presentation, FMX.Objects, FMX.ScrollBox,
  FMX.ListView, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ComboEdit, FMX.Memo,
  FMX.Memo.Types,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Data.DB,
  Unit2;

const
  LOGOUT_ICON_B64 =
    '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' +
    'Z8wAAAAASUVORK5CYII=';

  NAV_HOME =
    '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' +
    'lsCmJCVmegAAAABJRU5ErkJggg==';

  NAV_VODA =
    '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' +
    'LwUOk+HC4wAAAABJRU5ErkJggg==';

  NAV_NALOZI =
    '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' +
    'lJkPz/rBXQwAAAAASUVORK5CYII=';

  NAV_OPREMA =
    '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';

  NAV_MAGACIN =
    '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' +
    'QmCC';

  BACK_ARROW_B64 =
    'iVBORw0KGgoAAAANSUhEUgAAASwAAAFOCAYAAAA8QSAkAAAQAElEQVR4Aey9C3Ac13km+v+nZ/Ac' +
    'AANQIEECJB4ECIAgRTGKl6BkiZBvUolvRDm+WdnWw5ZlW7mx99peO1Zqs9fJyq44qchJVo5Xckll' +
    '2bGSLZcf5VyJMrVVm1LRXlsw6WtbICWSkkiRIEGADzwGGMwM5tW9339mBgQpUAIJApgB/mb/fZ59' +
    '+vR3Dj98/XfjwJBuioAioAgUCAJKWAUyUNpNRUARIFLC0lmgCCgCBYOAElbBDNX8O6otKAKFjoAS' +
    'VqGPoPZfEVhBCChhraDB1ltVBAodASWsQh9B7b8iMBsCyzRPCWuZDqzeliKwHBFQwlqOo6r3pAgs' +
    'UwSUsJbpwOptKQLLEQElrNlGVfMUAUUgLxFQwsrLYdFOKQKKwGwIKGHNhormKQKKQF4ioISVl8Oi' +
    'nVo8BPRKhYSAElYhjZb2VRFY4QgoYa3wCaC3rwgUEgJKWIU0WtpXRWCFIzBPwlrh6OntKwKKwKIi' +
    'oIS1qHDrxRQBRWA+CChhzQc9PVcRUAQWFQElrEWFu6Avpp1XBJYcASWsJR8C7YAioAjMFQElrLki' +
    'pfUUAUVgyRFQwlryIdAOKAL5h0C+9kgJK19HRvulCCgCb0FACestkGiGIqAI5CsCSlj5OjLaL0VA' +
    'EXgLAkpYb4Fk/hnagiKgCCwMAkpYC4OrtqoIKAILgIAS1gKAqk0qAorAwiCghLUwuGqrKwUBvc9F' +
    'RUAJa1Hh1ospAorAfBBQwpoPenquIqAILCoCSliLCrdeTBFQBOaDwNIS1nx6rucqAorAikNACWvF' +
    'DbnesCJQuAgoYRXu2GnPFYEVh4AS1oob8qW6Yb2uIjB/BJSw5o+htqAIKAKLhIAS1iIBrZdRBBSB' +
    '+SOghDV/DLUFRUARuBSBBUspYS0YtNqwIqAIXG8ElLCuN6LaniKgCCwYAkpYCwatNqwIKALXGwEl' +
    'rOuN6Pzb0xYUAUXgCggoYV0BGM1WBBSB/ENACSv/xkR7pAgoAldAQAnrCsBotiKwGAjoNa4OASWs' +
    'q8NLaysCisASIqCEtYTg66UVAUXg6hBQwro6vLS2IqAILCECBU1YS4ibXloRUASWAAElrCUAXS+p' +
    'CCgC14aAEta14aZnKQKKwBIgoIS1BKDrJa8BAT1FEQACSlgAQXdFQBEoDASUsApjnLSXioAiAASU' +
    'sACC7oqAIpBPCFy5L0pYV8ZGSxQBRSDPEFDCyrMB0e4oAorAlRFQwroyNlqiCCgCeYaAElaeDcj8' +
    'u6MtKALLFwElrOU7tnpnisCyQ0AJa9kNqd6QIrB8EVDCWr5jq3e2/BFYcXeohLXihlxvWBEoXASU' +
    'sAp37LTnisCKQ0AJa8UNud6wIlC4CKxkwircUdOeKwIrFAElrBU68HrbikAhIqCEVYijpn1WBFYo' +
    'AkpYK3TgV9pt6/0uDwSUsJbHOOpdKAIrAgElrBUxzHqTisDyQEAJa3mMo96FIrAiEJgTYa0IJPQm' +
    'FQFFIO8RUMLK+yHSDioCikAOASWsHBIaKgKKQN4joISV90O0yB3UyykCeYyAElYeD452TRFQBC5F' +
    'QAnrUjw0pQgoAnmMgBJWHg+Odk0RWFgECq91JazCGzPtsSKwYhFQwlqxQ683rggUHgJKWIU3Ztpj' +
    'RWDFIqCEdc1DrycqAorAYiOghLXYiOv1FAFF4JoRUMK6Zuj0REVAEVhsBJSwFhtxvV4hIqB9zhME' +
    'lLDyZCC0G4qAIvDOCChhvTNGWkMRUATyBAElrDwZiOXUjUceeaToz//8z1d94QtfWH333XdX9fT0' +
    'lCB0ltM96r0sDQKLQVhLc2d61SVDIB6PV7iu255IJLYWFRVtKC4urr5w4YJ/yTqkF142CChhLZuh' +
    'XPobgbIq+cpXvrJm8+bN7bfcckv37/zO7+z64Ac/eNtDDz20/Y/+6I/WQmWVwlRpLf1QFWwPlLAK' +
    'dujyr+N+v7/K5/PduKp61R3bt2//fZDW+99187+7/8atN72vrraua3JychV6XQTTXRG4JgSUsK4J' +
    'Nj1pJgKirB577LE1ra2t7TduuXFHQ0PDzmBVcEtVZVVnZWXl9qqKyh3NLRtveeCBB27auXOnKq2Z' +
    '4Gn8qhBQwroquLTybAgEg8EqN+Fuq6qo6tnSteU9TY1Nv+X3+avdtGcQ+gOBQMOGhobf/61tv3Xn' +
    'unXrNqvSmg1FzZsLAkpYc0FJ68yKgCirRx95tG7d6nUd8Ft1r1u7rltUVVlZ+VrH+EqYmB3jOEX+' +
    'omCgPNAeDFa/a2Pzxp0P3JdRWrt37y5TnxbpdhUIKGFdBVha9VIEyqgs6PrdbVBQu7q6unqaNjRt' +
    'LyoqDnquR8YYchyHmJkcJIqKiooD5eUbNqzf8Pvbtm+7s+6Guq5YLHbD1NRUMelWmAgsQa+VsJYA' +
    '9EK/pFVWjz5a17SpqX3rlq3d9fX13ZXwV5WVl9eBnErI84g9siZxImJwlgOnvFVaNTWr3tXasWnn' +
    'Qx97aNsdd9xRB5Wlbw9Jt7kgoIQ1F5S0ziUIlJWVBY1rtlVUVfRsvXFrT1NzM5SVP+im06jH1lzX' +
    'pXTaBV951tIog/JyioqLiisqAhuaGht/f/vN2+9cv269+rSAmO5zQ0AJa244aS0g8O1Hvl3y+KOP' +
    '161f39zR2dXVvbYOPquqYEe5VVa+EiImZpaAXDwWuiAtCC3KbSwbGZ/f8VeLT6u6uua3mza27Lwv' +
    '69NSpZVDSsMrIaCEdSVkFjq/ANuPlkWDbpHZVhMM7trc2dmzfsP6m+Qxz4WSwiMfic/KOEyMWeV6' +
    'oq5cIsaOPMf6swx5QmIeWMvxFUOpbWiob/j97fBp6dtD0m0OCGBqzaGWVlnRCOSU1er1qzs2tbV2' +
    '161Z011dXd1REaio8xkHPisiZiY2MIZRxpBL0xsToYjg3iJs1qflc3zVIK2Omuqad23c2LbzYx/7' +
    'mH6nBXB0vzICSlhXxkZLsgiIskpR6qZAWaBnU1tbT+P6DTeVlpUGHceQMQ4ZNgQ+yjrZCSGTg3wx' +
    'com8tEcuTMjKGNRlBnHZh0VTVOQvLi8va9ywYf17b7zxxt2qtEi3t0HAvE2ZFq1wBGYqq46uju51' +
    '9eu6q4M5n1VGWRF4R8jKQoW4kJMHZjJQW2KSj6QlKMkHV1Eun7E5Rr7T8gcDgfL2ysrK7TfccMON' +
    't912W/OOHTvK5dzlYXoX1wsBJazrheQybEeUFfnopmBlsKdrc9eulpaWbWWBsiAb+KLgt0qnXDjX' +
    'xYSpoKTATPJmUJztIrnYYQInWWQkz4NfizDjOEtmUib5qGD8Pn9xSUnJ6mAwuL2rq2tbW1tbEPm6' +
    'KwKXIIDpc0laE4oAffvbeBv4+ON169av62gVn1VdXXcQbwMDgUAd/E4lfBlGLBliNt+DmhLyEgOR' +
    'iQRDwIwKMA+kZs3WzRyQ5SZTqSS2BDPHfT5f0nEcPExmyvWoCOQQUMLKIaHhNALRaDRIKeemQGWg' +
    'p7Ojc9eG9Y3biouLg0I0LpSVC3+U+KIcn0OO3yHjMxklBU6SfCaGz8qldBLqC3WlYccxZKCs5NxU' +
    'Mk32uywwleM4lHbTyRC24eHhYxMTE/tOnTr18zNnzozIeWqKwEwEzMxEfsa1V4uFwCOPfLvk0Ucf' +
    'r1tds7qjtXVj9+q6uu4q8VkFyuqMMSWe61n1BD5Cl0BLnDFChpCZiClmtsTEhA3KSvIQI2aGYboh' +
    'L1cXj4NuIpGIT01NnZ+YGD84Nja2f2Rk5OVvfOMbJ7773e9G5Dw1RWAmAphBM5MaX8kIlJVFg76L' +
    'bwN3NW7YsK2krAQ+KygmkJULM/BLGSczbayDHQpKiEyUkwvFREwkviurvlCPGRmETR7wQFaGDTmO' +
    'QwZl6XQ6CUU1Pjo88vrYyNie06dP7x0cHOyvqamJ79u3Tz6bx4m6KwIXETAXoxpbqQjkfjewee3q' +
    'js7Oju61028Dy+CzckregguIxyqnXChkJJWQxi4xYmZiPAIy26Q92CgOLrZkImmVVXhi8uDoWKh3' +
    'YHDgwJe//OUjP/rRj8ZAVimckGsKUd0VgQwCSlgZHFb0saysLOhL+6zPqqtj866WpszbQFFBHlSV' +
    'mHGYrA8q5ZGLt4OEjZntN1c4kpE4TOpaE7WFOh7jIGayIYJUKpUcnxgfHxkdfW1kdOS54ydOPt/f' +
    'P3Jy9erVUyArVVbASPfZEZBpNHuJ5i57BHLKav3a9R2dmzvtelbB6sx3VoZNiStkZXUOZxQTCImB' +
    'Sm4lBomTHGDMTNjxahA7FFeWr1AbO2cMj4xp+KymopHo+fDExMHQyGjv6ZP9+7/ylUcO//jH3xsF' +
    'WamyAlS6XxkBJawrY7PsS3LKSr6z6tzctau5pXlbaVlJEBqKkokUpRJJIpCNKCtGREzeCIpJXB4L' +
    'haQYs0h4LUdSHgoyhtNRgZnBYkzy4cI4trGx0aMjF0aeOwllNTKoyop0mzMCmGpzrqsVlwkCb1FW' +
    '8FnViLIKBOocn6+EhGDAMUSMf4SNKfeYx4w8w8jL7BmiAj3l2ArZzBfLkZRz0/F4fCoiyioctj6r' +
    'wVODv3gEyup7qqwEohVp13LTSljXglqBnyPKCrdwU2Uw2NO1dcuuluaWbaWlpUFmhk+KrD/KX+Qn' +
    'f5EPaUOe9Vt55MobwRnEJFH5REEeHV27CoNHDDITRWaYcYnMnoCHfSw0FhoZGTkyOjry7JmB08+P' +
    'j46rzyoDjx6vAgElrKsAq9Cr5n43cP365o6uzq7u+nVru4NB+KwC5dnvrFz7MMfMlCGd7PQQZkIJ' +
    'wazSgm+LZMtxUi5EuY3ifIKBzOCzik/ForFzE+Fw38jocO/AwMD+L/31lw4/86Nn9G2gYKh2VQhk' +
    'Z+RVnaOVCxQB+d3Ai+tZde1qamraVlKa+YI9mUyRGEgGtOORBzUligoJEvKxfivDUFmu/YJd6oGT' +
    'iJFnyc0YVGNbnSzBESXhtBqfmBgbDY0eCYVCz50ZOPPjwQv6nRXpds0ImGs+U09cUgSu5uI5n1WN' +
    'rGfV3jK9nlW5KCu8DUzL45xQjZVHaNkjcqGiRE0R8hmzhEFMeFZESnI8G6Lm9M5yrhwQpj3X+qxi' +
    '0ei5yclw39joaO/AqVMHvvw3+p3VNGAauSYEMBWv6Tw9qYAQEJ9VkSnaFqwM7NrY2tbTsKHhJnkb' +
    'yMR4c5eidCpN8mW63+8jZqgkS1YuSMklwgxhh4lkhxkoKTFJg9dISM0KKpQxMzHbNpPyMnB0dPTI' +
    '8MjwHlFWIxMjJ/ULdtJtnghgOs6zBT09bxHIKavWptb2zq6u7rVrM+tZBcrxNtBxSnI6CTRDQkIM' +
    'MgJLkTUQD02rKg+KCwQGZmLMmByBebZi7vZBdNPKKgZlFekbHRntHToztP+//NV/Ofrd7343pN9Z' +
    '5bDS8FoRwPS71lP1vHxHwCqroqJt5RUVPZ2dHT0tLS03BQKBoJBTWlZdgJISZeUTZeWBcLJ+K/FP' +
    'OT5jVZeQmfiz0rLCApQYMZGQFmU3iTNLJlEimUyOh8ZDYqSmPAAAEABJREFUeBt4dHR4eM+p06f2' +
    'nh87r78bmMXqmgM9cRoBJaxpKJZPJLeelSir9rbO7rXr1u4IBvE2UP66DZRV7k5BMxBRBiYx5Moz' +
    'HgIhpRmBRN/WXC8Nn9XUVBQ+q3B4om90dKT31EDGZ6XK6m2h08KrREAJ6yoBK4TqIA77dwNFWbW3' +
    'b+ppqG/YnlvPKp1O28c7xzHkGIfwlIc0mAo7M5PBYyCDscQ35UJxeajAzCTrXjkO6sOtJfn2aRDn' +
    'oJgSiUQyNBYaGx4eOTIyOvbc6YHT+jaQdFsIBJSwFgLVJWpTfFaPPfbYmtra2vaWVrwNXLu6Oxis' +
    '7gjI20BZz0rYBX0D/4CSQEsSAekgiyRKTMTM1mQ1YyEtkg15xhhikJkkLVkh4orPKiHfWU2dmwhP' +
    '9o1AWQ2dOrNf3wYCHN0XBAGzIK3mU6MrqC/BYLDKdd1tgbLs28CG9TeVlZfCZ8VQUa41x4GyglIS' +
    '0hFSYubMIyHICFHJtqqLOUNcCEBgNL2xxHBgzJy0m0qGJ8IQV6GjY2Nje/pPDuw9P6k+K4FIbWEQ' +
    'wLRbmIa11cVDQJTVo48+Wrdu9bqOzZs2d9evq7d/3aYCbwNlDXYixj+6uGVV1cWMTLlkyyOgzWcc' +
    'YTbP0hjS2d3z3HQimZiKTU2di0Qm+/A02DswMHTgb/7uy0fUZ5UFSYMFQUAJa0FgXdxG5W2gcc22' +
    'ykDlrs6Orp6mxubt9m0glJS84RMzxoHPylA65cIyS06JepKeenhUxE4irWwcBMWiuGA2jUIPebYu' +
    'SEy+YA9NjIeGR0ZeOz86AmV1Aj6rfn0bKACpLSgCZkFb18YXFAFRVuKzampoat+yecsO+buBeCrs' +
    'LJe3gWxKPBcecpANOMY+9jF0FkuPMrJJYhmzmZmoEJOYpKYJTRKwnM8qEo2en5iYOBgaH31pYLB/' +
    'f/74rNBJ3Zc1AkpYBTy8QbCTm4DPSpTV5q6exsam7aXwWUEq4c1dkmRNK3AUGTjMCRFmJgeqy/E5' +
    'JBu4jBgzgDnDWJKWfLGMsiJiZmvkMSWTqeT4+HhoZGT06PCFC3tOnTila7CTbouJAKbrYl5Or3U9' +
    'EBBlNe2z6tjS3VDfgLeBVZ2BikCdz65nRcSU2zIxz4VuguBikBfjUU9Kc6QkBJeJe/Y8cJQUTxvO' +
    'Tcfj8aloJHJ+YjJ8cGx87KVTp07t/4sv/8URXYN9GiaNLAICSliLAPL1vsRFn1VwV1fX5p7mxsbt' +
    'ZaWlQQbdyPLFhgz5i/zk9/tJ0jm/lZsGY82UUQSqQtrFo6MYKI2EzESRmSypoQqUVTIZwjYyPHI0' +
    'NDL63Jmh0z8+P3pe17MScNQWFYEZhLWo19WLXQMCufWsWhta22U9q3X1dVZZ2VUX5DsrEI8oJWYm' +
    'SzqM4cWjHHlkNyEkISZX1JbNyRwyVbKVQHqUNbSVTiQSUFbR8+EJKKuxsZdkPSv96zak2xIhgBm9' +
    'RFfWy141ArKelSky2yqqKno6sz4r+buBQkTwL0EJpfCiT1Iw+UpdDAoK/EWOD7rLYZLfIUwn8ZYQ' +
    '/CQqKmMoM4aYOdsnFCKWSqWSE+GJ0Gho7OjoWEi/YAcmui8tAmZpL69XnwsCOZ/V2oa17a1trd1r' +
    '167bUV0d7BBlxcwlV1rPCm/1iMBBjMc7a4wECAzKiTIb0ojIkZmJmZEiggKbVlYTUFZ4Gnzp3MDg' +
    'fn0baOHRwxIioIS1hODP9dLisyoysupCeU/rxraehoaG7bKeFeFZLwW1lE5dYT0rkJMlKiEskBEz' +
    'kzEOzJBsQlwgJ6vKUGQJi5lJlFVoPDQ+MjZ6dGR49Ln+kyd+3H9Bv7MSzNSWFgGztJfXq78dAtM+' +
    'q6aMz6q+vn5HdU11h/3Oyjgl4CsC2xDjn5FHOlgmD62CeDhLVEjZpY09+K4kzziGUIzszKMfInb3' +
    'PHdaWUXCk32jo6O9J/uP60qhFh095AMCJh86oX2YHQHxWbnG3VYh61lt7uxpbMLbwPKyoAERueKf' +
    'AgH5/D4SY3jOPeTZfCgrBz4rx+eQkJnki99KlJgQlZyfu6LEmRnJzHdWVlmNDr82fGF4z8CJU/Zt' +
    'oK4UCnh0zwsElLDyYhgu7UROWa1tWtve0d7RvW7Nuh3BqmBHoDxQ55uxnhUJHbEhAxPKseqKsNkE' +
    'oZTesommutxc17XfWUXkOyv5gn0s9NLAqYH9X3r0S4f1O6u3QFhwGcupw0pYeTiaoqzkbWBVeVVP' +
    'W3s7fFbrp9ezctOy6oJHxmEYhs8lIigrgsJiUJRVTAg9qC8X+R7UFjOT43fIQHGRzcdJWdYSx3w8' +
    'mUiOjo2OXxgePjo6MvLs4KnB5+XvBqqyIt3yDAGTZ/1Z0d2ZfhsIZSVvA2vr1thVF8oDZXVGvrMC' +
    '+QjPgI+Ak9ATzGaQzQIvETPyYLJ0jJAWyYZHSJxPBqGtbg/i/oLPKpmYikaj5yfCE31jYyP2O6u/' +
    '+Ju/OKJ/N1CAU8s3BJSw8mhEcm8DS0vxNrCtrWfD+vU3lZSXBBlE44oygpmcspJ+g8DAUNiZSEYS' +
    'JlyUyWabD+5CiMoMw86Ef0zEzJR207Ke1XgoNH50fHzi2dNDZ58fmdC/bkO65S0CmOJ527e86Nhi' +
    'dCKnrGTVhc72TlnPakeVrMEOZeW7xGeV7Y1lJcQlJI/wNEgEEiLZhK0kFEOeVJHHQpKI5MFAfukk' +
    'lFUsFjsfnpyUVRd6B4aGDvzt3/7VkX/7t38b079uA5B0z0sElLDyYFhEWcl6VhXlFT2dHZ09TY2N' +
    '2wMBvA10DMljnZhVVqK0Uh65KfigpN8zCEl4SogpZ6LKxHJpbwZjpVKpZGhifHx4dPS10Njos/2n' +
    'B58fGTl7sqWlJf6DH/wg27hcQE0RyC8ElLCWcDxmKiv53cD6hvodwerMd1aGTQmUEAkREeQTMxMz' +
    'jMj+QjOLYkKamMgaYUNepj7i2KUIwTRVpdNpN56IxyPRyIWJiYmDodDoS/0Dg/v/5m++fFiUFcgq' +
    'jfpoBUfdFYE8REAJawkH5RJltTmznlVJWUnQI5eSiRSlEkkSMhJnOSMiZnyGxCQupMWMGIyw5ZjG' +
    'A0VljIg5Uy5lyVQyGZoITYyOjb42OhZSZUWXbZrMewSUsJZgiC5RVl1bu+sb1u+oqQ52XFzPiomw' +
    'E7ZsQC4c7vJ4x8wkj3ooyqovG0MclIRdzmNmyZw2N+26cWzRGHxW4fDBkdHRXlkpVJXVNEQaKRAE' +
    'lLCWYKCmlVVFVU9X5+ae5qbG7aVl2fWs0B8DwrHrWRX5kaLMCgupNN7quVY7SaYHeWVVFIhMyMy9' +
    'ZGkZJmmDsptVVqHQxPDw8Otj8FkN9J96fnBwsF99VlmANCgYBJSwFnGocl+wNzU1tXd2dXWvXVfX' +
    'HazJrrog31ldRjrMGB55BZhVTkJQQkzysadkXd51KScRVyA8gqGem0gm4tFI1PqsRkfHXjp98vT+' +
    'R77yyGH5gl19VpcjqOl8RwD/I65TF7WZd0RAvmB3i9xtVVBWmzs7epqaGm8qKSsOim6Ce4mghOyj' +
    'nRCP/P6fNXjRwT3kiO/KcEZtJeEbl3ykGWZgEopJJ+z50GLJNHxW46HwSGj09bHQ6LOnBk7uOTty' +
    '9sTq1aun9u3bh0aktpoiUDgIKGEtwljlfFa1TbXtm9o3da+tW7ujuromu56VvA1Mg15maCZEXXnU' +
    'k8/VoZiEiHKGiiC1TKdRRJlXhgjAasw2h8RnNRWfSkSj0QuTsgZ7CMrqzOn9f/3Xf31YlBXIKkUk' +
    'LeGouyJQQAgoYS3CYInPqsgUbZPvrDa2tvXUr2/YXoq3gURMqWSKZBUFx+eQ+K2YmeS7Ky/3eJhT' +
    'T8hn1HcM3hLC5FxxwnsgNglRTMyoAYNSS42Pj4fHRkdfxxvB/+/M4Onnzp6dPKG/G0i6FTgCSlgL' +
    'OICirOzfDWxqbd+8ZfOOdevqd1QH8TawPFDn2C/YIaWwEzEZkBAzE0laDHEWskJI2KCayBIT8mQ9' +
    'K5wyXRXFdndRSZRVbCp2PhKJ9I3IGuyDA7/40pdk1YVnruMX7PZyelAEFh0BJawFhFz+bqB8wR6s' +
    'rNzV2YG3gc1N2wOBQFDIKZ1ddcHnd8jv94GoGI9yHgweLfinHPisHKguBjOJLysNv5UoMSSJZdQ4' +
    '03HDTMxM4puPpxKpEHxWwyMjUFYjVlmdOTN+UpVVBis9Fj4CMvUL/y7y7A5ybwPXrdvQsamjo7tu' +
    'TV13VbCqs3xaWWU6zAgY7GMNcdlFXJEtIBuAycjmUWaTeMZwZDGSzx1cUVZQVcPj4fFDwyPDv+g/' +
    '3b9flVUGMz0uHwSUsBZgLKNl0aBbZLaJsmrftKmnAT6r4uLioDzSpdNpcuGfchz4ohwHfOSRhzRE' +
    'FTEzGeQjAqXlkagwOYcNkwMlZqC4CBXlfGExRJH0KJFIpMZGxyLDF4aPDZ+/sKf/1InnR0Z01QXS' +
    '7XogkFdtKGFdx+HI+axqG2rb2zZt3LFmzWooq2BnIFA+vZ6VXA68hICJcbSkg5CZCTtMQrZEJGQl' +
    'j3qSL0RmQFzQVCA5nIBdvrOKx+PyNnB4fHz8FVFWx08e3//3f//3h7/5zW+qzwoY6b68EFDCuo7j' +
    'KT4rN+FuC1RW3t7WlvnrNmVlpUEhGlFFYg4UlHGgrCCRXLAVM5NhQ9gJbEXCRkJUzBniYs6EKLA7' +
    'UrYaM0OBpVITkxPh0dGRY+fOnn3+9aOv/fiNN944CfKa+tWvfqXfWVnE9LCcEDDL6WaW6l5yymr1' +
    '6nUdm7ds2VG/bl13dXWwo6IiUOfz+UqIhGbo4iYyCSa51piyNeTxEAXYCRszIx8R7F728wXJANG5' +
    'yWQiHo3GLoQnwodGR0d7jx07tv8b//CNw9/5zndGEU/KKTDdFYFlhYAS1nUYTlFWCSirykBgV3v7' +
    'pjuampq2l5eXVRvjkCWatEfGOOQYQ+mUS25KxA9DWYGQhJTkuU9IyiVy7dtDlwyYyUgZQlFc4s+S' +
    'MmTBB5ZOyttAENVrFy5cePbYG8ee6z/W/2ZyPBlrHWjNkZVHuikCywwBs8zuZ1Fv5xJlhbeB9Q31' +
    '3dXB6s6y8rK1Rn43UL5Ul8c+9CpHPow4ngbtB+oEopIXfTYL9YSYwE/EzMSGibC7aEMeJaG9CAzk' +
    'pZGYmpqKjIyMnh44ffr1g785+Po//9M/D/3617/2Gm5uqKh9b2317t27V73//e+3dvfdd9e8k917' +
    '773V1v4A4Qz7A8TF/vAP/zD4h3lsuL+qt7PF6vvb9WG2srfr10c/+tHgfffdV4mxLNu8eXMREX6G' +
    '4bDSdyWsecyAmcqqq2tzT3Nj0/bS8tIggVoSiSTe3onYwUyDsiKwDzOTA/+VfF9F2ISgQEIkoQsV' +
    'JqFxDDl+Q+zA8Y520nirCJIigzSa8OJT8fR4aGLs9KlTh0BSbxw9erQoEAyuL6+qai7zl7VRCbX7' +
    '/f52It8m5qI2+NSsEflbrSWplWBod2PGzMZ43IXFN8ad+MakP6d5kasAABAASURBVNkili5ONxdn' +
    'zXGc5pyh7aaZhrefjbMaFzeWOqUbFsN8rq/RvYJJ2WL0Qa4h17pSPy7Pl7pyjlgxsGLmRjFMC4sv' +
    'fig142fT+kgkUhsIBCpAWj6UrfjdrHgErgEAUVaPPvponfistmze3J1TVrKeld/nK8HEu6RVS0ry' +
    '6QIe+RjkxSyws/AaTEqz1WdGobiyuZcGqGMcx1QEKoobGxtX7+rZtfXD991z6z0fuvu2D33wQ7d/' +
    '4N9/oOdD//7envs/9KGeez/0wZ777v9wz/0f+cguiVv78P099953b88D9z5g7aP337frgfvu73ng' +
    'vgd6HnzwwV0PPIB82P0PfKTnQdjHce7HPvyxHrGPP/DxXQ98+MGemfaR+x/smc0++uDHdn3kgY/2' +
    'LJZ9Atf6OK450yRvsa4v1xGTa87sw2xxqSN1PwJ8P/Kxj/R89BMf3fWxjwFja5/o+fCHH+i59977' +
    'd911513vuuWWW5obGxuru7q6RGVdOhdWYEr+56zA257fLcvvBrqu2VZVUdHTubnjjpam5u2leBvI' +
    'xER4zDNkqLioiIr8flyI4ZdKUwp+q7SbJg/Oc2SiHo4gH+ElMSE5MQ9Ky02JnwuFIDhRY+AntGHT' +
    'XFRU5KyqrlndtaXrljvuuON9t+/a9cFdu3bd09PTcw/SH3rPe97zwf/jPXd86I6e99zznl133Ntz' +
    '+6773mK77rjv9ttvv1/stnff/uHb3v1u2O0ffjfiObvtlts+Inbrrbc9MNNuQ3qmvfuWWz/67lt2' +
    'vsVuubX7wcW2W2/pfnCmLfb1c9eb2YfZ4rl6t9x6y4M7d4rtfPDdt972UbHbb7vtgXffeusDO3d0' +
    'f/jm337X7s72zm21tbV11dXVeHmDObPCdyWsq5gAOWW1du36jq1dXd3yNrAmmF11wXAJJDyIyCMh' +
    'HgMlZURJeTaLiMlunlVaYCKbyhwYZcz2gAwmITB5PJSQcSKzHIkk8PkcU1JaXF5ZWbkek7gjGKzq' +
    'qqyq2loVDG7JWTBYvaVK8mDBYHBrVWXVjVUzrarqxkqkM1aJeMYqKgLb3s4C5eU3zW4VyM8DKyvf' +
    'Hphp5UvUp5l9mC2e61eg4iYo5ZvwxAf8AtNWWVG5rbKy4qbKikBHeXl5XbGvOIC3zfpISAQpgIPu' +
    'c0NAlJX8bmBNMLhrc1dnT3Nz803isxKHuKy6kEwlSZzkknZFKcGEeJiZRCkZwyRv+9JJvCUEGzEz' +
    'SChnZOPGYZJ6hE3OdUWRgfSMY8hxHFsHRZeQmqSZc+1cGkobs5mck7PZyjUPo4gxWnAcML5e1lz8' +
    'MBPzPJcdx8cgKREUnBsnDSl/CCufB+ORR75d8uijj9etX9/c0bV1a3d9/bru6qrqDrwNrDPEJR4m' +
    'GpFHnLsJDynkeZiIzEwMohISYmYUYEe5VJUkG6RxriU6D8oLVRj1mRFBJc/+p5FIJk1yFTkfhiKS' +
    'jSVPIrCZcTSLHOyoa+O5EFnTu+RNJzSy2AgwLsgyfowIdiEsF/MGUTbGkBjiVI5/Eq50w3+XlQ7B' +
    'O99/WVk0WFTkbhNltWVL166W5pZteDMWdJMuJeJJEsXkc3yEt2eEKUbih7IGRmFmMjDGpBRzDGrA' +
    'CGnLFQzCYg/KK02yGoMlOZQZH5OB2hKikbZc+T4rhZ/6VrWR3Rj1ps1DDCYFaA6NIiYXuIIx6lqb' +
    '2YbGFw8BmRNiGGMZZwfq2TD+O+Jnlow1flDJTmxYRhCDqbsgAIQkUJsNAfFZ2fWsGmrb2za2dtet' +
    'Wd0Nn1AH/Dh1jnFKMKMyxIBpLj8J7YST6SXGIBADQyhtZychYQKScQA7IxeEJm0gQCKzSzyTJ40Q' +
    'sdQTI7kUCCtTgSSLmREySi7u06nM6XLSxcJsbLrOdJptO3pcTAQAPsZIfkDJeDOSJjueLKOBHyiU' +
    '+VoPP/AMapJuQAD/c3DUfVYEQE5VbkJ+NzBw+6ZNbbsaGtZvK/L5qzHJ4BknYmbyF4mygj8UE8yF' +
    '+nGhhGQCOj5Djs8hmXyikESFiYJCBnEWdamXxhtBKTeOQwb1xTkl9dIJUVwuMTPaMdaMI5f14CfD' +
    '/GVCGREhpBlbls9m5GSizEzMM42QXiJjvS4TEwaSUomUNcwpYmZyMA98jo+YkPCIyZVqLpNuFgFj' +
    'j3q4BIF//Md/LP7qV7+6un5N/SZZKbR+XX23vJErD5TXMZsSV1gBU8iAQIwx8hOQGP/k8c02xPYo' +
    'OZnIW46cKfNQgAmJIxnDJO0R5inNtkm+2GxluTxp7zJjlIkhsPvMuM2Qw2Xn2PvQPFowHATznAnO' +
    'MgcQMjHJPGDMBURlJ899p0GnFbUpYc0y3PF4vApvA7dWVFXctmXzFvFZbcdr5qBj4FAAWblwqAu5' +
    'CFl5mGwulJVMboO5JXky8eQnpuSLimJmcvyO/elJLhPBFyUhY0oy4whDlJiZDEhQlJlThPpQabic' +
    '/QZLVBjhWqht6xGT3cTDcUVDDUZFa/IfAoashfuPKO2rzQlfGVdmxpzwkeODokIcQ0XMGC0mYjwO' +
    'ytwiQ4QKROUIdbdwKAyXIZBIJJxoLFrKzMHS0tI6WK1jnBLDBhOJrGWOnJmcRJk8ZmLOmEw2IS2S' +
    'DXlCZGJCLkJunM1nw/YcIiaZxNaIiBnXkjLCliMBRJlRn9heV+oiK7NLnUzs4nG2vIultg3py8ws' +
    'jS8CAtPjwiRzQuaVjIPMF89GZGgkNl2RCne7vj0317e55dHaG2+8ETt15tQAiOtUMpkK4U1gHGop' +
    'LXPJgY/BOA6J/0EmGIM8DEiEDGJMUsUSDzMTsxghpBkbk83IBVKHGD9PcS5eZ6fli3iYbRt+MWbG' +
    'pEa5tJ8zlrpimNS5OY08NEPT28x0Li6h1M/ZdGWNLDYC8oNLTK4rKtx+nyf+TMwB+UGE8cdPMCKI' +
    'ecLrY6KI1FRTwpplDrz22mvxkydPnp+KTR2PRCJ90Wj0CMhrDI+CKZCCZ0Ai9v+8zCwhAaSxE8rI' +
    'shVhQ77NQ1TqZpgMCeTjaHebb2PZg2RcbrZROQkFuJ7EyOYRrgWzDUuYMdS6mCOVxaTokgJkXJ5G' +
    'lu6Li4AdAoypENb0lSVzOkFkpifUjMwVHFXCmmXwGxoaEpOTk2PnhscPHzp0+Lkzg4M/Bmn1JxPJ' +
    'uOd5aTmFQRpiEs8ZyjC9oHpAGWxQCsN8JPy0JAmlnpCYmE3DJ2XLUF/mqeQbx5CYxKW+mLSbxttH' +
    'Fyat49KSTRLKebk8G0fDUl/iUm6NwG3IQBHZNCNNM0zSagRBu7hGHhSUi6NHBnPFgc+SEWJoiJk9' +
    'awbzgYswepKrpoQ1yxz4wQ9+kO7t7Y398If/cu6pbz3Rd+JEf+/E+MSBSCx6FEorZJWWUBD+k9vT' +
    'MZ0sGUhoMwgTjoikXApyRhdJwpZJuRjypTkJGAWMSOYUNCgJMckTs48Ms+RLnctM2nBRXwynEpqm' +
    '6W1m3elMjSw6AhgHFhOiQgQje2kXWL7BSl2at4JTSlhvM/i1tbVJKKvQ0OnTr/2m7+CPT58ZeCES' +
    'iVqlhf/8aSOTDOdbRQNiEILAj0sUIfPyHZNSyq2ikgiQZ4eIHSZGXLKEWFw4LVy05abT9qevOLek' +
    'juM3ZFDXhTffRR08K9jzZl6MGe2hTyyGuPTL+sTQloeOSTkCy5qMa1pDPclXA3aLjQXGyckpahlI' +
    'TAKZH3Z8iYihsjwv7SHtJfyJt3AZrcAN03YF3vUcb1mU1r59+6ZefOnFc//0z9/se/P4SSit8QOT' +
    '0cjReDwRSrtuCqTgESa6bdIjwiSTAxFJJoxhRCAfD+ZSTkl5YA4xSWOeokZmt7XRjuQhyGTOPEqm' +
    'LbRnZ0rkJOShL0jbCpS7vA0JG0t9KZM4upG9vs3NnivnqwGRRcJDRoFAWoQ5gquShx9Ugr8kxTBS' +
    'dld9ZWGwByUsC8M7HhKlpaWjQ+dPH3n5Ny//+NSp0/8jPDHZH49NxV3PTRMIg5mJMfmYESKD0aQ1' +
    'qCIPkVQqRWKeIA4Tf5T9+j0JH4Z8l4U6otiMgZJiQw47ZPCPXLa/mwhqtKEtRx384LVpXIpwSZKJ' +
    '7kJ5WV8XQvkPwLi2/Z6rCK5bEJQr/xHxhOGBvGxd1JNQ8tU8WgoMLEmBqFzXs9eXccTUsTumgcwA' +
    'z7ioYHP0YBSCd0ZAlBYs9tOf/vTsN5/5Zt/x19/oDYVGD0xGJo8mkgnr03Ix8zyQgpj85AQ3WBLx' +
    'QAoeHuMkT2afTEJrIKiZVwaHEGf/GTCQjQvTZUWR1JU2MXe9VCrtJhLJVCKRSCblTUAikZqKx9Px' +
    'eCKdTCZTyJU0bArxBGokkvGEhPFE7h9SyErgFFgyHo/DkDd1qcWRhiUSscTVWDIRRTsX7WrOnU/d' +
    'y697pXQC/csHi6MfMKAfTSDEQEVTyVQ0CQPe0XgiHkun0/KiJ4U6M2aCzIaVaUpYVzfuiUAgMHLu' +
    '7LnDfQf7nh88M/hCLBrrx+SKp11oGyEn/DAEqYCfPJIwlUgRSsjxOfb3DkX1sGGSN4GS5+DNkEGa' +
    'QE45XhNi8nDwCHOUiRjlBmoJhOeBCLxYLJYGWcbDE+HYBCwTTsTxZjMejUXjkUgkLn+bcGx0LCY2' +
    'PjYenQyHI6gXCY2PT6IsHA5PhlFvAueIjSOEhWGTocnJcGgyPDk2bZOI5ywyOYpri40gfKtNTo6g' +
    'rbdaBPmzm7R10SZnXEvikenrXayTyRu55PqTaH8BLByZHL4WmxWDGf2zbU5ODk+EwxfCk5MXItHI' +
    'BYzdhamp2IVoJDI8Hh4fnpiYGI3EImEQWcyJOmnSDf8FFIQ5IwCVlYbFfvqjn57956f/ue/N/jd7' +
    'QxPjB6Kx6JFkKmm/07qotLLNCuEgKgQlj3MMFQUuQk5mZ0YOTLiJpl1cGaISh7snLIYTUEtI0MNP' +
    '4DReBEyMjoyduHDhQl94fOIXIJ6fxaLR/xWdiv0v/KT+KaTTT5D+STQasWEsHt+Hn9D78BMb4dS+' +
    'qan4PpAs4vGfSJhMJBBP2LypOPKmEEcYT2bPi0/9JJ5EHbE4QmvIi+fKZ4QJiUvZDLN5kn+5SZ1c' +
    'e9lQrjHT7LWyZZfE5dwZ7dlrSN47Gc6RunO12e5xLnnv1L60kYhhLKI/icdj++K4tyTuG/NoH34o' +
    'IX/qJ7Gp2C+TieSJuBsfi/liicyMWdnH5aKwFncUGyhRGisdvTB44fArhw7uOTM0+MJUfKo/lU7F' +
    'Xcr4tORHgfEx+Yp81pgZhIM9Dd0Ec2Ee1JiYEBWeH7GjDOQEuiJ2cEsYHReqLZ39AtpNux4mdQrK' +
    '5+wbb7z2s5///Gfff/Xwq08Nnj3z2Eho5O/GQqGvjk2M/11sMvLVZIr+FvX/Fi3+LV4SftUh56sg' +
    '079Dq39P5Pw9G/oHMZT9V+T9V4g4CR9D+Bi59DVrhNBkjdx/JDF2v07W6Ovkdy41QtoaymimZfMv' +
    'r8+oY9vKtYlQrjHTLi+fTuPcXHv2mnIN5F1y3dnS3n8jmrvBg/j4tdhV3UKYAAAQAElEQVQ7XSPT' +
    'Jj+OR77HyfM/7jj8OMYBoWND9pA29N0ir+iXyB/csGFDDOGK382KR+AaAIDKSv+g9wexZ77/4rkn' +
    'nvp234njx3snwuMHYvHYEUzAMc/zUh6YyBIPMzGzvYonZJQjKZuDg1RCQFJFTOJi9hxMa5Tb85DH' +
    'zGTAgvLLsoRX3iNjofCP/+f/PPbx//vjv4L1fuDeP/rZ3ff8Xz976NMP/ay9q+Vn7Vvaf9ba0frz' +
    '1o7Gn9e31r/U1NqUsbaG3oamjDVJvLnhFw0zrQ1p2Prm9fvf1tavPbB+prUgbW39gfUtMy2bP7Ou' +
    'xN+p/XcqlzbE7DXlGjOvWRjxlvaWAxs2rv3l2g0Zu2HtDTa+YeOGX27btu2Vez5+z+C3vvWt8COP' +
    'PKIvC4lICQsgXOveAKU1OVk8dnb47JFDfYf2nB0c2otHsv50Kh1Pi1MrlVnTCkrH+rNckJUYVA8x' +
    'kGf4pRiShpiQZsqlmZlIPBYu8lHIzISdHJ9jAoEy/6pVNXUdHe07b9v17ltv7OraUF6+qjyVSvGx' +
    'Y8dShw8fTu3bt0/OBtWRborAskIA/22W1f0s6s2I0uqF0vre97539oknn+g7/mZ/bzg8cSAajx1J' +
    'JBNjUFtWac3slJAVHhdAQCAhYjwGSgo1mEhIyaagxKxPC5QjhCZG2OADY3+R3yktL62suWFVc8O6' +
    '+hu3btnyrs/+P5/acs8999TefPPNxXfffTdasmfjjOW5612tXASUsK7D2MsX8XBqj10YHDrym77f' +
    '7Dk9cHpvJBbtT8OnxQ6njc+QvAlkqCkxInAKyMj606G6co98QmY2LoQFzpG6BipMTM6x2TjV53Oc' +
    'MmzVweqW5qamO2+8cev7GusaO0vckuDAwEAR6aYILFMElLCuw8CK0sJj2NS//PBfzonSev3Ysd5x' +
    'eXs4FbNvD9Oum3KFiYSEQDgM4pq+LNLIJk+IC4+A4DESPhNjKROji5tthtn4sZWUldRUBCo6V1XX' +
    '/LuNm9p2/sln/uTGD77vg7Xvfe97i+Hz0LG9CJvGlgkCOqmv40DmlNb584NHXoVPa3DwzN7JyUh/' +
    'bGoqnoJjy4WkYmYStUUICWQEBUYSuimPxBhkxni7KPkemMzFG0IxsvLKI1feLsKYmXw+nyktK/VX' +
    'VFasb2io/z9vvPHG3fUb69tisVjF/v37/aSbIlDoCFzWfyWsywCZTzKntH74wx+ee/LpJ/vePPZm' +
    '71ho9EA0OnkknohnfvdQmAdE5YGMxOR64B7hLImSRJhRgTKb8JSYTYn8EpMEQsPMIC2npLg4WFER' +
    '6KiG0mpsaN75qT/+1I13/e5dN2zevFkeD3WMBS+1ZYGATuYFGMac0uo/03/01cOv7hk4M/hCNBbp' +
    'TySTcdf+BqBHorbEso94ZPxMBsqK5LEQCorsxmTYkPwjj0n+GYMjc8Y3j7oSBWmZstKy4sqKysba' +
    'VbW721rb78Lr8baqqqoASMtHuikCywQBJawFGMic0nr22WfPPvnkk32nTp18aXx8/EA0Nml/91B8' +
    'Wl5WaeUuz8xkYKAiS0aEDUlLUsyMEBl2RxzqisSQFvXFbNjvL3JKSoqrKyoDm6tXVXc3NzfvfPjh' +
    'P9/6p5/8U1VawEn35YGAEtYCjuO00urvP3ro0KE9g4ODe6ORSH8ylYgTU9qYLPzCOlBLloSgpAiF' +
    'dPnGlCkW5zzIiuVUyZM0TKpDaTkgrJKammBzfX3D7s5N7e+rXlPb5jg15aq0BCG1QkfAFPoN5HP/' +
    'c0rr+9///rmnnnqq7/jx472hidCByGTkaCKRCLlpN4VHQqErS0b2ABK6hK/sCHnkui4eJsFqtjbu' +
    'GqSFY3ZHAqTFbBhKy1daWlpdVl7WhUfE7g2NDd1f/OLntn7yk59UpZVFS4PCRcD+dyjc7hdGz3Nr' +
    'xA8PDx/p6+vbMzAwsDccDvfH8PYQfqw05UhKRiMXl1tDnJEn61elUmkSk7qMfA9+LjE2TGJ4zKR0' +
    'Ok3yeYQxDhzxJaWB8vLm2tobdre3td61evW61poaVVoCq1rhIoD/DoXb+ULpuSit3t7e2DPPPJNR' +
    'WseO946PQWlFMz4tkBaUlgvt5EFkQS3ljshxPZdchPaBUEYrZ4y7t1Vxji1HWnaJe2Qc40Bs+VeV' +
    'l5dvqQ5Wdzc1Ne783KdVaQlEy9NWxl3J9F8Zd5oHdzmttIagtF7ue34Ibw9j0Vh/MpGMQyFhz5CP' +
    'i8c7AvGIWkon0oRHRzI+h3xFDsn3WSyqymFijF46DUKD2jJIOz5k4D7lPDxqks/xOYGyQFmwKrhx' +
    '7Zq63a3tm+5as2pNWxXp20PApHsBIpCZ4QXY8ULsck5pvfj9F8/993/67y+/eeJU78RE+EA0Gjma' +
    'TCYzK5eCrUBb0FgX75ARNSAkYwyeCDO/f4isizsqsJRxpkzIClGCzMp8EV9csqq8rMwqrZaWlp0P' +
    'P/Lw1k9/4tO1ra3vLSZ6xFxsSGOKQH4joJN1KcangRLFk8VjFwaHDv+mr+/5gYHBF+DO6ocPKg6y' +
    'yvi0MDLsY3KKHGvMbJ8KrXqCAgOvWVJzHEMQUsScIStRYx4c9MxMBkY4zcFWDi98sKJq49q6dbs7' +
    'OzrvWl2/elNVVayitVW/iCfdCgYBUzA9XdCOLm7jorRkPS1RWs9881svnzzxZm94cvxAdCp2NJVO' +
    'haCQsj4tIjZMzExEQkigM5CVByNskj1djkdIeYxENSmxUckSVmNm4/f5/cXFxavg0+qqrKzqbmxs' +
    '6f6zz396659+6q4bWltbobRI5wKQ0z2/EdBJupTjk1VaQ6NDh1/+9cvPnxk480IikeiHSrp0PS0Q' +
    'lJCUWEZZecQYOQaZCSHJ20IXfiwhKMcxZODL8qCy0niz6Mm5KAAJkjHGAWmVgbRa1tTW3tnZ0ba7' +
    'Zk0NlFYVlFar/u7hUs4FvfacEMC0n1M9rbQACEwrrWdePPctKK03Tx7rDYcnDkSiUfudFh4R5Vei' +
    'vdylJQKNhSRiDNUFAxfZR0UhLmvIQ4lVWKhIJAmYEBYRuMzn+IuKi1bBF99VXVOzo7m5GUrrz7Y+' +
    '9NBnalVpASHd8xoBJax8GJ6c0rpgldbF9bTcdJztelpMCImhqMSI+SJJZftvpAz5orY8l8gwlJYR' +
    '40x1MJuoLUZeUZHfgcoqq6yobFmzdu2d7Zs7dzc04O1h1YpQWlnENChEBJSw8mDUckpLvtP6+lNf' +
    '73vj2Gt4ezh+IBqD0pK3h56bci3beJZ8mDnTay8T5I6SK2bTiDDjQBljhIwCMZCZ8fv81qcVKC/v' +
    'qg5W72hpbNr5+c//2dbPfOYzup4WcNI9PxFQwsqjcbnkO61DL+8ZGDyzNzI52T8Vi8dT6VQapEXM' +
    'TCarpggbE+MIwQXywk5WiTnZPPivCMYek2FDbAyJ+hIVxqjs8/mc8tLyMrw9bFlXv+7OrVBaa9bo' +
    'elqkW94iYPK2ZyuwY6K07Bfx389+EX/8jd7RUOhAOBI+eqX1tOTXdixnCUeJ5XCTOAxPgiRL1jAz' +
    'GVQUoqLshrTxYysuKV5VEQhsrpIv4usbdn7yoU9ufW/Pe2vVp5UFSoO8QcBcZU+0+iIgkFNaAwPD' +
    'Rw4d6tszJKs8zLaeFpjIOuFBTOwQgZOgoJAjqgoJI0qMUAg1JUTFzMSSx/KJBOV89OSH0iorLSur' +
    'ClQ2r1mz5g82tW7avapuVVuV+rRIt/xCQAkrv8bD9iantL6fU1onjveGw+GsTytxceVSW/viAbxE' +
    'VlEhAk4CVXGGlS5WQQx5OKJQjpn6zMbv8/tLoLQCFRVdNatqdrS1tXX/58//561/+qk/vUGVloVK' +
    'D3mAgBJWHgzClbqQU1qyysPBgwefHxwYeCEaifbL7x4y8/R6WvLJgvjkxaStLCVJ9KIhEzxGUkf8' +
    'WCwjD7PptJQQ4elQ1tMqq7mhpqWhvuHOzVs336nfaV2EUGNLj4BZ+i5oD66EQE5pvfjii+fwBvHl' +
    'N0++2Tsu62lFI1mfVjoFsvIoS0bT7TAyJFMCO8Ieua57yXpaGSXm4ZSMoR3CKQakBaVVsqo8UN4l' +
    'X8TLd1qf/8znt37qU5+6YbOuEU+6LS0CdjovbRf06nNAIFFcXDx24cKFwy/3vbJnYOD03nB4oj+G' +
    '14eul05PO94xmgwfFYhnuklGnpSnUunp9bQIea6s8iC+LqkPc9004UWkVWB4o+iUFJeUBcoDLWtW' +
    'r72zq2vrnWtr17cFAoEKkJauET+NrkYWGwFM3cW+pF7vahEQpQXLrqf1RN/rx17vHQuNHYjk1tNy' +
    'M99peXCji9n2IaE8mHwKIWadWTLaMBFgIr5QXXZUnz7LViNi4zg++0V8IFDeVV1d3b2xuXHnw59+' +
    'eOsnPvHpWpCW/jUe0m0pEMD0XYrL6jWvBYGcT2toaOgIfFp7zg6e3RvLrqeFR740zD76SSgPei4U' +
    'VDKRojTUlPx+4cz1tIxjiJkJVEdu2iP5HURZ9UH65eE8ITsHm3wRX10VbFlbv+7O9q7O3Wtrg6q0' +
    'BKTlZgVyP6ZA+qndBAJQWene3t6YrBH/9NNP9x0/0d87Ln+NJxq1v3sIoknBhKtQG4HIKBh4iYSg' +
    'jDHE+CeySkJGrdzOUoZHQ4gyErKy5+AEPzb5TgvEBaUV7N64sW3nw5972K6ntXnz3VBaup5WDkMN' +
    'Fx4Bs/CX0CtcbwRySmt44OyRlw+9smdwaGhvfCreDx9UZj0ty0gMkmK8+fORz+8jBhlJNqWJxORr' +
    'd/J4WlkxM8nbQxdqzIODnkFsRs4hQh3HKcNWVVnVUr9u3Z1dnV131a2vg9IahU/rVR+q6K4ILAoC' +
    'SliLAvP1vUhOaT3z/RfPPfXUt/tO9J/snQiHD8RisaOpVCoElZTyPBcBETNbE3KSDGSDmKC+iJAP' +
    'MwYhE+ExkKQCosglqSFJwsbMRr7TguPfrqdVFQzuqK9fD6X1J1Ba76lVnxZA0n1REDCLcpXlfpEl' +
    'ur+GBkpMThaPnT175sjBV17eM3h2aG8ykby4nlYybf1XLnxUOaISv5Z1scvIO2AnsJKoLVsHLOU4' +
    'hsTf5UFlQbGRByLzpA7MGOOAtMrKy8pb1qxZc2d7e+fuNXVrWgMBfXu4RFNgxV1Wpu2Ku+nlcsMZ' +
    'pfUD+/bwiSee6DspK5fOWE/LdV0oLTDNZTcMXiICVxE2WyoZOWO2RTYf5TbBREJaSBqfz/EXlRSt' +
    'CuDtYRBKa0PLhp3/6Qv/acsnPvEJVVoASPeFRUAJa2HxXZTWcz6tM1BaL//65T1nBk7vjcVi/el0' +
    'Og7fVdr4mBASM8GY5B/Bf0UugYlg2A38VczwY1k1RmQYSsvAHCZkW8Ly4ORix1BRsd+up1VVWblx' +
    'dV3dna2bWu9CH1RpAUfdFxYBJayFxXdRWs8orczfPZT1tI7L3z2cmLC/e5hMJexf4wHZeMRE4CFi' +
    'CYkIgTXKbpekkWDGQcokEMvWZjZm2qdVVrYlGKzZ0bShZecXvvCFLcv/L0wL8mB4CwAAEABJREFU' +
    'IGpLhYAS1lIhvwDXhcqBT2ty7OzQ2SOvvHxwz5kzg3sjk9H++FQiDrWVtm54EA9DNRFC24UsKckj' +
    'oIcMKRNDNKOqrApjMmA6hgrzxKcFFUbYfHg+lPW0qgIVG+ugtDrh06pfUy+rPATgiNe3h8BI9+uL' +
    'gBLW9cVzSVubVlp4e/jE09/uewNKKzQ2diASiRyNJ2SVh3TKZc+TX9URx7uE9plQyCtnuTuQtMQ9' +
    '0BhIi5kJD4jE8ihJmY2ZjR9bcUnJqnIoraqq6u6GDQ07P/fpz21VpZXBSI/XFwElrOuLZ160lnt7' +
    'OAyl9fKrr+wZGDqzNxKL9idTSfudlhBVGg6sNHxSEieQEztEjNAqKKgoZiYDRUXgKzFGyJzJY4av' +
    'C0QmpIcoWaWFd4eV5RUba29Yvbu1rfWuVavsGvGqtEi364nAIhPW9ey6tnUlBDJKC28P7XpaT/Qd' +
    'P/FG78TE+IGorPKQjGfX0xJWEsq52Ao4CY+BSCMiREQgMKSwIwPHy5LIEX3mETOUls/vly/iK2Q9' +
    'rZqa7tbWlp0PP/ywKi2Lkh6uFwJKWNcLyTxsJ+fTGh4YPtIna8QPDeyNRiJQWok4MaVZFBT6jYdE' +
    'yikrJFEkx8sMbCX05oLnpL6cy8iTtOvimRHV5a/xVFQEympuWCVfxO/ubO/avW7dhlbHccrVpwWA' +
    'dJ83AkpY84YwfxvIKK3e2DNWaT3Vd/z48d7QROhAeDIMn1Y8+/YQz3a4hcwREdmFiSxtgZGypOaC' +
    'qFz5tR1b0SOyoVSG2SQORNanVVIsPq3yrorKwM7GhvqdX/ziF1VpASbd54+AEtb8Mcz7FhoaGuzb' +
    'Q1m5tK+vb8/AwMDecDjcPzU1Ffc8N83MxJw1ISjO3BKySJSU+NlTqZRdT4tRxsx2hQcXbwsN6ksd' +
    '101T7st4xxj5Ir6srKy85YbVN9zV3t5x17rV61prampUaWWg1eM1IqCEdY3AFdJp00rrmWfOPfXU' +
    'U33Hjh3rDYVC9u1hAm8PXffiF/HetHLCAyDinjjmYZBURJgtnCUocJbNQhVAgbo42l2ElsfGZ3z+' +
    '4qKiVYHyiq5gVXBnY1Pjzs997nNbP/vZz666+eab/aiL1nDUXRG4CgR00lwFWIVeNae0cutpIdwb' +
    'jcX6E8lEPO2m0yAuPOl5lAkJoUe59bQcn0P+Ih+xwySkJcvVSOimXKu2HMeQ1CFinEgkbxb9jt8J' +
    'lAXKqiurW2pXr7mrdeOmu2pq1rSm0+lykJaDWrorAleFgBLWVcFV2JVzSuvS9bSgtPD2EKRlfVog' +
    'K9FIuNFsgBgoiAwIyRgDOmKQGjKxSz4CuzOjjFEGX5cHY2IybIx8ES8+rYpAoGtVsLq7dUPjzr/6' +
    'f/9q6x//8R/fANJSpUXLY1usuzCLdSG9Tv4gkFNaM9fTmpqasr976JGXtvII5GMcJr8/u54W0qKa' +
    'PPitxMR/JY+DjmPIcRxiBlmB40B4UGYu0kRGHh+JpdyRv3tYWVG1cc2aNe9r62h7X/2a+taKigpV' +
    'WqTb1SCghHU1aC2Tujmldfl6WtFY9O3X04JyEvUkJlCAo4iZycDkw1JCOcnGlvIo4/ryyIC68Hjo' +
    'Ly4uXlVWVrYlUBHYWV9fv/M//of/qEpL8FKbMwJKWHOGavlVzH0Rfy3raTFmDhvO/KqOaLIU5BVe' +
    'Jzo+0BPMc8W3lSYXJOaJFEOxw8bB42Ep/Fottatq72rb1H7X2tq1G9Wntfzm1kLdEabdQjWt7c4V' +
    'gaWql1FaP3ib9bTSl6ynBc7BU6EcySor0FVWSpENRWUxGcrkcyYPATIQl/PYOD6fv0iUVnn5lqqK' +
    'SlFat3z5L7+8RX1apNscEDBzqKNVljkCOZ9Wbj2t0wOn7e8eptLpODuUWU8L/iyrqOTxT/AQ/hGT' +
    'OEzKCGUEHxdBcUFnkWMcknwGaYnK8qC2jGG8bfQ75Xg2hA8LPq26uza2bXyfKi2AqPs7IqCE9Y4Q' +
    'Lf8KGaXVa5WWrKf1xrHXMr97CJ9WMpkMuZ4LpQW2ARTMDF5iKCYkZhAWUtM7Sm0dZib5lymQWMYM' +
    'm8zbw5LiVWXlZVsqKqt21q+vv+Uv//IvVWllwNLjFRBQwroCMCsxO6e0hoeGj7xy8NBzg2fO7I1M' +
    'RjLraUFuiUpiBulAJTHzJRCJm8pmOMgXk4dH4TiXrJ/LoL6oK0KaJB9UhsdDp7S0tKwyENhYuxo+' +
    'rba2961du3ZjdXV12c033+zQctz0nuaFgBLWvOBbXifnlNb3nv3e2SeffrLvzTf7XwqNhQ6AtI7K' +
    'elqum05BWnnMDDpCLHf74CjwTzYF2TXNXtksBMzZSii2J0sesfE5jt9fXLSqHD4tPCK+q7Kycuvv' +
    '/d7vNd59991lqKK7InAJAkpYl8ChCUGgtrY2GY/Hx86dGTx66JXDzw1AaU3Fpk4mk6nMelogHVFb' +
    'GZMzCNRDRMYjPDxaE1IS/xXJDGOQm5CYGCMhhric7yJ0jHFK4dPCXl9SUtLd3Nz82y0tLTVoUXdF' +
    '4BIEZDpdkqEJRUCU1r59+6YySuuJvpMn+1+S9bRisdgRkNaY64KWhG0sVJ5wU8ZAZDZLDuAlCS43' +
    'yRazigwRZqvW0JqbxCHBzEljTNrv989s7fJmNL1CESgswlqhg7RUtz1Tab1y+JU9Z4eG9kYjsf5k' +
    'IplZTwuEI33z4JPy5Dss+KcY/ivjZ7LqSgqRJ34r5mweIxMm5QZ1HZ+4qrz4+Pj4SCgUei2dTr8Y' +
    'iUR+nkwmh1FTd0XgEgSUsC6BQxMzEcgprf3P7j/7nSe/03f8ZH8viOVANBY5kkgkxtKum8IjnVVC' +
    'UF0EhUSMGcVGVJMoLxge+STftguiklBOQAnh/HQymYhOTU0NRSPRX09OTvYi3vfYY4/1f+ADH4hK' +
    'XTVFYCYCmF4zkxpXBN6KQKQ2kqyMV44N9p86eujwq3vOwKc1ORHuT8QTUx57afFdCQG5npt5NMRR' +
    'SMoFWYlJWcbgywJpSdyFKktMJeIjI6MjwxdGXpmKTv0rSPB5KKyBX/3qV2n0QngNge6KwEUElLAu' +
    'YqGxKyAgSuuf9v3TVEZpPd137M1jvePh8f3RaORIMpUccz03BeLyrIMdJOWBjISwxMRX5QlJiYHI' +
    '5BKu66ZBdtFoLDo0GY78enw8/LNwKHzgH/7hH17/3d/93QnUcYmylZHQXRHIIaCElUNCw3dEIJJV' +
    'WufOnMPbw0PPnzk79EIsOnUylUpPGR+nHceQB7Jy09BQ0EfMTOLTEkMOGEgyPTwKpuMT4fGR8fGJ' +
    'V5Lx+L9GJ8J7JxOTgyBGF51AJRx1VwRmQUAJaxZQNGt2BEAoaVFa34NP68mn/6Wv/80TvaHxsV9G' +
    'ohFZ5QFKC673DDNZcoLqIsYMY8ajIHLS2BLJZDQ+NTUUi8Z+HZmM/Gw0PPrLrz/59deyykrJanbo' +
    'NTeLAKZTNqaBIjBHBGqhtOJx+LTODB49+HLf8wOnT78wORmRt4dTeARMi6KSpuSREE+IoCqP8NhI' +
    'eHyMT0xMjOBx8pVEMvGv49GxvfF4/AyIUJWVALZybc53roQ1Z6i0Yg4BEEx6H3xa8td4nnj6ib43' +
    '3nyjNzQ2diAajVqflue5KTjiPfFpIU7ptJuCQz0ai8eGItHJ30yGJ38+Njn2y69/XZVVDlMN54aA' +
    'EtbccNJasyCQ+93DgaGBI4dePrRHlFY0Ej2ZTKWm2HDaOEwueR7IKj4ZCQ+Pj4denYxMPjs2OvbC' +
    '0NCQ+qxmwVSz3h4BJay3x0dL3wYBUVq9vb2xZ5999uyT33iy7/Vjb/aOhUJQWpm3h3BZTWGLxKai' +
    'Q/BZ/SYcDv98eGz4wEP/4aHX3//+98vbQPVZvQ2+WvRWBJSw3opJoeUseX/tF/FOfOz86OCRvoO/' +
    '2XP6zOm9kWjk5OTk5MT4+Pj5UGj81YnwxHPDo8MvDA4Onjl8+HAKnVayAgi6Xx0CSlhXh5fWngUB' +
    'UVryu4c//OEPz33tv33t4PFjx/H2cHw/COsX4cmJn09MjL90YejCLz/72c++dt99942jCRemhAUQ' +
    'dL86BJSwrg4vrf02CIjSchxnbCQ0cuTw4VefO/Tqoe+8eeLNZ84Pnv8f50PnB1RZvQ14WjQnBJSw' +
    '5gSTVpoLAjml9d3vfvf8008/ffBrX/vaL774xS/+/5/87Cdfh7ISn5Uqq7kA+TZ1VnqREtZKnwEL' +
    'cP+itCbwHIhHwjEorsjJkyeTuIyQFQLdFYFrR0AJ69qx0zOvgEBOackbxF/96ldCVmlUVZ8VQNB9' +
    'fggoYc0PPz1bEVAEFhGBFUVYi4irXkoRUAQWAAElrAUAVZtUBBSBhUFACWthcNVWFQFFYAEQUMJa' +
    'AFC1yTxAQLuwLBFQwlqWw6o3pQgsTwSUsJbnuOpdKQLLEgElrGU5rHpTisDyRGB2wlqe96p3pQgo' +
    'AgWOgBJWgQ+gdl8RWEkIKGGtpNHWe1UEChwBJawCH8D5d19bUAQKBwElrMIZK+2pIrDiEVDCWvFT' +
    'QAFQBAoHASWswhkr7akiMF8ECv58JayCH0K9AUVg5SCghLVyxlrvVBEoeASUsAp+CPUGFIGVg4AS' +
    '1tzHWmsqAorAEiOghLXEA6CXVwQUgbkjoIQ1d6y0piKgCCwxAkpYSzwAevn8REB7lZ8IKGHl57ho' +
    'rxQBRWAWBJSwZgFFsxQBRSA/EVDCys9x0V4pAorALAgsCGHNch3NUgQUAUVg3ggoYc0bQm1AEVAE' +
    'FgsBJazFQlqvowgoAvNGQAlr3hCu8Ab09hWBRURACWsRwdZLKQKKwPwQUMKaH356tiKgCCwiAkpY' +
    'iwi2XkoRKGwElr73SlhLPwbaA0VAEZgjAkpYcwRKqykCisDSI6CEtfRjoD1QBBSBOSKghDVHoOZf' +
    'TVtQBBSB+SKghDVfBPV8RUARWDQElLAWDWq9kCKgCMwXASWs+SKo5ysCb0VAcxYIASWsBQJWm1UE' +
    'FIHrj4AS1vXHVFtUBBSBBUJACWuBgNVmFQFF4PojkI+Edf3vUltUBBSBZYGAEtayGEa9CUVgZSCg' +
    'hLUyxlnvUhFYFggoYS2LYSzcm9CeKwJXg4AS1tWgpXUVAUVgSRFQwlpS+PXiioAicDUIKGFdDVpa' +
    'VxFQBK4dgetwphLWdQBRm1AEFIHFQUAJa3Fw1qsoAorAdUBACes6gKhNKAKKwOIgoIS1ODjP/yra' +
    'giKgCJASlk4CRUARKBgElLAKZqi0o4qAIqCEpXNAEcg7BLRDV0JACetKyGi+IqAI5B0CSlh5NyTa' +
    'IUVAEbgSAkpYV0JG8xUBRSDvEFiGhJV3GGuHFAFF4DohoIR1nYDUZhQBRWDhEVDCWniM9QqKgCJw' +
    'nRBQwrpOQGozS4KAXnSFIaCEtcIGXG9XEShkBJSwCnn0tO+KwApDQAlrhQ243q4iUKgISL+VsAQF' +
    'NUVAESgIBJSwCmKYtJOKgCIgCChhCQpqioAiUBAIKGEVxDDNv5PagiKwHBBQwloOo5bmmssAAABK' +
    'SURBVKj3oAisEASUsFbIQOttKgLLAQElrOUwinoPisBMBJZxXAlrGQ+u3poisNwQUMJabiOq96MI' +
    'LGMElLCW8eDqrSkCyw2B/w0AAP//NFGmOQAAAAZJREFUAwCe8EJPehX/rwAAAABJRU5ErkJggg==';

const
  CLR_BG       = $FF0A1628;
  CLR_CARD     = $FF0D2444;
  CLR_CARD2    = $FF102A52;
  CLR_BLUE     = $FF1E7EC8;
  CLR_BRIGHT   = $FF2196F3;
  CLR_WHITE    = $FFFFFFFF;
  CLR_DIM      = $FFAACCEE;
  CLR_GREEN    = $FF4CAF50;
  CLR_ORANGE   = $FFFF9800;
  CLR_RED      = $FFE53935;
  CLR_YELLOW   = $FFFFC107;

type
  TfrmMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    { Login }
    procedure btnLoginClick(Sender: TObject);
    procedure btnGoRegisterClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure btnBackToLoginClick(Sender: TObject);

    { Nav }
    procedure btnNavDashClick(Sender: TObject);
    procedure btnNavMerenjeClick(Sender: TObject);
    procedure btnNavNaloziClick(Sender: TObject);
    procedure btnNavOpremaClick(Sender: TObject);
    procedure btnNavMagacinClick(Sender: TObject);

    { Dashboard }
    procedure btnRefreshDashClick(Sender: TObject);

    { Merenja }
    procedure btnNovoMerenjeClick(Sender: TObject);
    procedure btnSaveMerenjeClick(Sender: TObject);
    procedure btnCancelMerenjeClick(Sender: TObject);

    { Radni nalozi }
    procedure btnNoviNalogClick(Sender: TObject);
    procedure btnSaveNalogClick(Sender: TObject);
    procedure btnCancelNalogClick(Sender: TObject);
    procedure btnAddFotoNalogNewClick(Sender: TObject);
    procedure btnAddDelNalogNewClick(Sender: TObject);
    procedure btnSnimiDelNalogNewClick(Sender: TObject);
    procedure btnOtkaziDelNalogNewClick(Sender: TObject);
    procedure cmbNalogFilterChange(Sender: TObject);
    procedure NalogCardClick(Sender: TObject);
    procedure MerenjeCardClick(Sender: TObject);
    procedure btnZatvoriNalogClick(Sender: TObject);
    procedure btnBackNalogClick(Sender: TObject);
    { Rezervni delovi u nalogu }
    procedure btnDodajDelNaloguClick(Sender: TObject);
    procedure btnSnimiDelNaloguClick(Sender: TObject);
    procedure btnOtkaziDelNaloguClick(Sender: TObject);
    { Foto u nalogu }
    procedure btnDodajFotoOtvarClick(Sender: TObject);
    procedure btnDodajFotoZatvrClick(Sender: TObject);

    { Oprema }
    procedure btnNovaOpremaClick(Sender: TObject);
    procedure btnSaveOpremaClick(Sender: TObject);
    procedure btnCancelOpremaClick(Sender: TObject);
    procedure OpremaCardClick(Sender: TObject);

    { Magacin }
    procedure btnNoviMatClick(Sender: TObject);
    procedure btnSaveMatClick(Sender: TObject);
    procedure btnCancelMatClick(Sender: TObject);

  private
    { Tabs }
    tcMain                          : TTabControl;
    tiLogin, tiRegister, tiDashboard, tiMerenje : TTabItem;
    tiNalozi, tiOprema, tiMagacin   : TTabItem;
    tiNalogForm, tiNalogDetail      : TTabItem;
    tiOpremaForm, tiMatForm         : TTabItem;
    tiMerenjeForm                   : TTabItem;
    tiProfil                        : TTabItem;

    { Login }
    edtUser, edtPass : TEdit;
    { Register }
    edtRegEmpID, edtRegUsername, edtRegPass, edtRegPass2 : TEdit;
    lblRegErr : TLabel;
    btnLogin         : TCornerButton;
    lblLoginErr      : TLabel;

    { Dashboard }
    sbDash           : TScrollBox;
    btnRefreshDash   : TCornerButton;

    { Profil state }
    FLoggedKoID      : Integer;
    FLoggedUsername  : string;
    FPrevProfilTab   : TTabItem;
    imgAvatarDash    : TImage;
    imgProfilBig     : TImage;
    lblProfilIme     : TLabel;
    lblProfilUloga   : TLabel;
    lblProfilDatum   : TLabel;
    lblProfilID      : TLabel;

    { Merenja }
    sbMerenja        : TScrollBox;
    sbMerenjaTop     : TScrollBox;
    sbMerenjaBazeni  : TScrollBox;
    sbMerenjaDetail  : TScrollBox;
    tiMerenjeDetail  : TTabItem;
    lblMerenjeDetTitle : TLabel;
    btnNovoMerenje   : TCornerButton;
    cmbMerBazen      : TComboEdit;
    edtMerPH         : TEdit;
    edtMerHlor       : TEdit;
    edtMerTemp       : TEdit;
    edtMerUneo       : TEdit;
    lblMerErr        : TLabel;

    { Radni nalozi }
    sbNalozi         : TScrollBox;
    cmbNalogFilter   : TComboEdit;
    btnNoviNalog     : TCornerButton;
    { Nalog forma }
    cmbNalogBazen    : TComboEdit;
    cmbNalogOprema   : TComboEdit;
    cmbNalogTip      : TComboEdit;
    cmbNalogKat      : TComboEdit;
    cmbNalogPrior    : TComboEdit;
    edtNalogIzvrsio  : TEdit;
    memoNalogOpis    : TMemo;
    chkBlokiraj      : TCheckBox;
    lblNalogErr      : TLabel;
    { Nalog detail }
    sbNalogDetail    : TScrollBox;
    lblNalogDetTitle : TLabel;
    btnZatvoriNalog  : TCornerButton;
    { Rezervni delovi u nalogu — forma unutar detalja }
    pnlDelForm       : TRectangle;
    cmbDelMat        : TComboEdit;
    edtDelKol        : TEdit;
    lblDelErr        : TLabel;
    { Rezervni delovi u novom nalogu }
    pnlDelNewForm    : TRectangle;
    cmbDelNewMat     : TComboEdit;
    edtDelNewKol     : TEdit;
    lblDelNewErr     : TLabel;
    sbDelNewList     : TScrollBox;
    FDelNewMatIDs    : array of Integer;
    FDelMatIDs       : array of Integer;
    { Rezervni delovi za novi nalog (pre kreiranja) }
    FNewNalogDelovi  : array of record MatID: Integer; Kol: Double; Naziv: string; end;
    { Foto u nalogu }
    imgFotoOtvar     : TImage;
    imgFotoZatvr     : TImage;
    imgFotoNalogNew  : TImage;
    FFotoOtvarData   : TBytes;
    FFotoZatvrData   : TBytes;
    FFotoNewData     : TBytes;

    { Oprema }
    sbOprema         : TScrollBox;
    btnNovaOprema    : TCornerButton;
    edtOpNaziv       : TEdit;
    cmbOpTip         : TComboEdit;
    cmbOpStatus      : TComboEdit;
    edtOpModel       : TEdit;
    edtOpSerial      : TEdit;
    edtOpDatum       : TEdit;
    cmbOpBazen       : TComboEdit;
    memoOpNap        : TMemo;
    lblOpErr         : TLabel;

    { Magacin }
    sbMagacin        : TScrollBox;
    btnNoviMat       : TCornerButton;
    edtMatNaziv      : TEdit;
    cmbMatTip        : TComboEdit;
    edtMatJed        : TEdit;
    edtMatZal        : TEdit;
    edtMatMin        : TEdit;
    lblMatErr        : TLabel;

    { State }
    FNalogCurrentID  : Integer;
    FOpCurrentID     : Integer;
    FOpIsNew         : Boolean;
    FMatCurrentID    : Integer;
    FMatIsNew        : Boolean;
    FBazenIDs        : array of Integer;
    FOpremaIDs       : array of Integer;

    { Build }
    procedure BuildUI;
    procedure AddNavBar(ATab: TTabItem; AActive: Integer);

    { Profil }
    procedure btnAvatarDashClick(Sender: TObject);
    procedure btnBackProfilClick(Sender: TObject);
    procedure btnLogoutClick(Sender: TObject);
    procedure btnProfilFotoClick(Sender: TObject);
    procedure LoadProfilData;

    { Data }
    procedure RefreshDashboard;
    procedure LoadMerenja;
    procedure LoadMerenjaZaBazen(ABazenID: Integer; const ABazenNaziv: string);
    procedure BazenMerenjeCardClick(Sender: TObject);
    procedure btnBackMerenjeDetClick(Sender: TObject);
    procedure LoadNalozi(const AFilter: string = '');
    procedure LoadOprema;
    procedure LoadMagacin;
    procedure LoadBazenCombo(ACombo: TComboEdit);
    procedure LoadOpremaCombo;

    { Cards }
    procedure AddAlarmCard(AParent: TFmxObject; const AText, ASub: string;
      AColor: TAlphaColor; var AY: Single);
    procedure AddMerenjeCard(AID: Integer; const ABazen, ADatum: string;
      APH, AHlor, ATemp: Double; AAlarm: Boolean; var AY: Single;
      AScroll: TScrollBox = nil);
    procedure AddNalogCard(AID: Integer; const ATip, AOpis, AStatus, ADatum: string;
      APrior: Integer; var AY: Single);
    procedure AddOpremaCard(AID: Integer; const ANaziv, ATip, AStatus, AModel, ASerial, ADatum: string;
      var AY: Single);
    procedure AddMatCard(AID: Integer; const ANaziv, ATip: string;
      AZal, AMin: Double; var AY: Single);

    { Nalog detail }
    procedure ShowNalogDetail(AID: Integer);
    procedure LoadDelMatCombo;
    procedure RefreshNalogDelovi(AID: Integer; var AY: Single);
    procedure LoadFotoFromDB(AID: Integer; AField: string; AImg: TImage);
    procedure SaveFotoDB(AID: Integer; AField: string; const AData: TBytes);

    { Auth }
    function SimpleHash(const S: string): string;
    { UI Helpers }
    function MkRect(AParent: TFmxObject; X, Y, W, H: Single;
      AColor: TAlphaColor; ARadius: Single = 0): TRectangle;
    function MkLbl(AParent: TFmxObject; const AText: string;
      X, Y, W, H, ASize: Single; ABold: Boolean = False): TLabel;
    function MkEdit(AParent: TFmxObject; const APrompt: string;
      X, Y, W: Single; APass: Boolean = False): TEdit;
    function MkBtn(AParent: TFmxObject; const AText: string;
      X, Y, W, H: Single; AColor: TAlphaColor = CLR_BLUE): TCornerButton;
    function MkCombo(AParent: TFmxObject; X, Y, W: Single): TComboEdit;
    function MkMemo(AParent: TFmxObject; X, Y, W, H: Single): TMemo;
    function MkCheck(AParent: TFmxObject; const AText: string;
      X, Y, W, H: Single): TCheckBox;
    function MkScroll(AParent: TFmxObject; X, Y, W, H: Single): TScrollBox;
  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

{ ===================================================================
  UI HELPERS
  =================================================================== }

function TfrmMain.MkRect(AParent: TFmxObject; X, Y, W, H: Single;
  AColor: TAlphaColor; ARadius: Single): TRectangle;
begin
  Result := TRectangle.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.Fill.Color := AColor;
  Result.Fill.Kind := TBrushKind.Solid;
  Result.XRadius := ARadius; Result.YRadius := ARadius;
end;

function TfrmMain.MkLbl(AParent: TFmxObject; const AText: string;
  X, Y, W, H, ASize: Single; ABold: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Text := AText;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.Font.Size := ASize;
  Result.FontColor := CLR_WHITE;
  Result.StyledSettings := [];
  if ABold then Result.Font.Style := [TFontStyle.fsBold];
end;

function TfrmMain.MkEdit(AParent: TFmxObject; const APrompt: string;
  X, Y, W: Single; APass: Boolean): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.Parent := AParent;
  Result.TextPrompt := APrompt;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := 40;
  Result.Password := APass;
end;

function TfrmMain.MkBtn(AParent: TFmxObject; const AText: string;
  X, Y, W, H: Single; AColor: TAlphaColor): TCornerButton;
begin
  Result := TCornerButton.Create(Self);
  Result.Parent := AParent;
  Result.Text := AText;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.CornerType := TCornerType.Round;
  Result.XRadius := H / 2; Result.YRadius := H / 2;
  Result.Font.Size := 14;
end;

function TfrmMain.MkCombo(AParent: TFmxObject; X, Y, W: Single): TComboEdit;
begin
  Result := TComboEdit.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := 40;
end;

function TfrmMain.MkMemo(AParent: TFmxObject; X, Y, W, H: Single): TMemo;
begin
  Result := TMemo.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
end;

function TfrmMain.MkCheck(AParent: TFmxObject; const AText: string;
  X, Y, W, H: Single): TCheckBox;
begin
  Result := TCheckBox.Create(Self);
  Result.Parent := AParent;
  Result.Text := AText;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
end;

function TfrmMain.MkScroll(AParent: TFmxObject; X, Y, W, H: Single): TScrollBox;
begin
  Result := TScrollBox.Create(Self);
  Result.Parent := AParent;
  Result.Position.X := X; Result.Position.Y := Y;
  Result.Width := W; Result.Height := H;
  Result.ShowScrollBars := False;
end;

{ ===================================================================
  NAV BAR
  =================================================================== }

procedure TfrmMain.AddNavBar(ATab: TTabItem; AActive: Integer);
const
  N = 5;
  NAV_LABELS: array[0..4] of string = ('Pocetna','Merenja','Nalozi','Oprema','Magacin');
  NAV_B64: array[0..4] of string = (NAV_HOME, NAV_VODA, NAV_NALOZI, NAV_OPREMA, NAV_MAGACIN);
var
  Nav: TRectangle;
  Events: array[0..4] of TNotifyEvent;
  I: Integer;
  L: TLayout;
  Img: TImage;
  SubLbl: TLabel;
  ActiveDot: TCircle;
  BS: TBytesStream;
begin
  Events[0] := btnNavDashClick;    Events[1] := btnNavMerenjeClick;
  Events[2] := btnNavNaloziClick;  Events[3] := btnNavOpremaClick;
  Events[4] := btnNavMagacinClick;

  Nav := TRectangle.Create(Self);
  Nav.Parent := ATab;
  Nav.Align := TAlignLayout.Bottom;
  Nav.Height := 68;
  Nav.Fill.Color := CLR_CARD;
  Nav.Fill.Kind := TBrushKind.Solid;
  Nav.XRadius := 0; Nav.YRadius := 0;
  Nav.Stroke.Kind := TBrushKind.None;
  Nav.HitTest := True;

  with TRectangle.Create(Self) do
  begin
    Parent := Nav;
    Align := TAlignLayout.Top;
    Height := 1;
    Fill.Color := $FF1E3A5F;
    Fill.Kind := TBrushKind.Solid;
    Stroke.Kind := TBrushKind.None;
  end;

  for I := 0 to N - 1 do
  begin
    L := TLayout.Create(Self);
    L.Parent := Nav;
    L.Position.X := I * (420 / N);
    L.Position.Y := 1;
    L.Width := 420 / N;
    L.Height := 67;
    L.HitTest := True;
    L.OnClick := Events[I];

    { Ikonica iz base64 }
    Img := TImage.Create(Self);
    Img.Parent := L;
    Img.Position.X := (420 / N - 28) / 2;
    Img.Position.Y := 8;
    Img.Width := 28;
    Img.Height := 28;
    Img.WrapMode := TImageWrapMode.Fit;
    Img.HitTest := False;
    if I = AActive then
      Img.Opacity := 1.0
    else
      Img.Opacity := 0.45;
    BS := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(NAV_B64[I]));
    try
      Img.Bitmap.LoadFromStream(BS);
    finally
      BS.Free;
    end;

    { Label ispod }
    SubLbl := MkLbl(L, NAV_LABELS[I], 0, 40, 420 / N, 16, 9);
    SubLbl.TextSettings.HorzAlign := TTextAlign.Center;
    SubLbl.HitTest := False;
    if I = AActive then
      SubLbl.FontColor := CLR_BRIGHT
    else
      SubLbl.FontColor := CLR_DIM;

    { Aktivna tacka }
    if I = AActive then
    begin
      ActiveDot := TCircle.Create(Self);
      ActiveDot.Parent := L;
      ActiveDot.Position.X := (420 / N - 6) / 2;
      ActiveDot.Position.Y := 59;
      ActiveDot.Width := 6;
      ActiveDot.Height := 6;
      ActiveDot.Fill.Color := CLR_BRIGHT;
      ActiveDot.Fill.Kind := TBrushKind.Solid;
      ActiveDot.Stroke.Kind := TBrushKind.None;
      ActiveDot.HitTest := False;
    end;
  end;
end;

{ ===================================================================
  BUILD UI
  =================================================================== }

procedure TfrmMain.BuildUI;
const
  FW = 420; FH = 720; NB = 76; { nav bar height }
  CW = FW - 32; { content width }
var
  Y: Single;
  BgImg: TImage;
  BgPath: string;
  Card, RegCard: TRectangle;
  btnGoReg: TCornerButton;
  NalogScroll: TScrollBox;

  procedure AddBg(ATab: TTabItem);
  var Img: TImage; Ov: TRectangle;
  begin
    { Pozadinska slika }
    Img := TImage.Create(Self);
    Img.Parent := ATab;
    Img.Position.X := 0; Img.Position.Y := 0;
    Img.Width := FW; Img.Height := FH;
    Img.WrapMode := TImageWrapMode.Stretch;
    Img.HitTest := False;
    if Assigned(BgImg) and Assigned(BgImg.Bitmap) and (BgImg.Bitmap.Width > 0) then
      Img.Bitmap.Assign(BgImg.Bitmap);
    { Tamni overlay za citljivost }
    Ov := TRectangle.Create(Self);
    Ov.Parent := ATab;
    Ov.Position.X := 0; Ov.Position.Y := 0;
    Ov.Width := FW; Ov.Height := FH;
    Ov.Fill.Color := $D0050F1E;
    Ov.Fill.Kind := TBrushKind.Solid;
    Ov.Stroke.Kind := TBrushKind.None;
    Ov.HitTest := False;
  end;

  procedure SectionLabel(AParent: TFmxObject; const AText: string; var AY: Single);
  begin
    MkLbl(AParent, AText, 16, AY, 300, 22, 11, True).FontColor := CLR_DIM;
    AY := AY + 28;
  end;

begin
  Self.Caption := 'AquaCentar - AquaOdrzavanje';
  Self.Width := FW; Self.Height := FH;
  Self.BorderStyle := TFmxFormBorderStyle.Single;

  { Ucitaj pozadinsku sliku jednom }
  BgImg := nil;
  BgPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pozadina.jpg';
  if not FileExists(BgPath) then
    BgPath := IncludeTrailingPathDelimiter(
                IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + '..\..'
              ) + 'pozadina.jpg';
  if FileExists(BgPath) then
  begin
    BgImg := TImage.Create(Self);
    BgImg.Parent := Self;
    BgImg.Visible := False;
    BgImg.Bitmap.LoadFromFile(BgPath);
  end;

  tcMain := TTabControl.Create(Self);
  tcMain.Parent := Self;
  tcMain.Align := TAlignLayout.Client;
  tcMain.TabPosition := TTabPosition.None;

  tiLogin       := TTabItem.Create(Self); tiLogin.Parent       := tcMain;
  tiRegister    := TTabItem.Create(Self); tiRegister.Parent    := tcMain;
  tiDashboard   := TTabItem.Create(Self); tiDashboard.Parent   := tcMain;
  tiMerenje     := TTabItem.Create(Self); tiMerenje.Parent     := tcMain;
  tiNalozi      := TTabItem.Create(Self); tiNalozi.Parent      := tcMain;
  tiOprema      := TTabItem.Create(Self); tiOprema.Parent      := tcMain;
  tiMagacin     := TTabItem.Create(Self); tiMagacin.Parent     := tcMain;
  tiNalogForm   := TTabItem.Create(Self); tiNalogForm.Parent   := tcMain;
  tiNalogDetail := TTabItem.Create(Self); tiNalogDetail.Parent := tcMain;
  tiOpremaForm  := TTabItem.Create(Self); tiOpremaForm.Parent  := tcMain;
  tiMatForm     := TTabItem.Create(Self); tiMatForm.Parent     := tcMain;
  tiMerenjeForm := TTabItem.Create(Self); tiMerenjeForm.Parent := tcMain;
  tiMerenjeDetail := TTabItem.Create(Self); tiMerenjeDetail.Parent := tcMain;
  tiProfil      := TTabItem.Create(Self); tiProfil.Parent      := tcMain;

  { ════════════════════════════════════════════════════
    LOGIN
    ════════════════════════════════════════════════════ }
  AddBg(tiLogin);
  Card := MkRect(tiLogin, 24, FH * 0.42, FW - 48, 258, $CC0D2444, 22);
  MkLbl(tiLogin, 'AquaOdrzavanje', 0, FH * 0.28, FW, 44, 24, True)
    .TextSettings.HorzAlign := TTextAlign.Center;
  MkLbl(tiLogin, 'Upravljanje odrzavanjem', 0, FH * 0.38, FW, 26, 13)
    .TextSettings.HorzAlign := TTextAlign.Center;

  { CardW = FW - 48 = 372; padding 20 sa svake strane => field width = 372 - 40 = 332 }
  edtUser := MkEdit(Card, 'Korisnicko ime', 20, 24, FW - 88);
  edtPass := MkEdit(Card, 'Lozinka', 20, 76, FW - 88, True);
  btnLogin := MkBtn(Card, 'Prijavljivanje', (FW - 48 - 200) / 2, 136, 200, 44, CLR_BRIGHT);
  btnLogin.OnClick := btnLoginClick;
  btnGoReg := MkBtn(Card, 'Registruj se', (FW - 48 - 160) / 2, 186, 160, 34, CLR_CARD2);
  btnGoReg.OnClick := btnGoRegisterClick;
  lblLoginErr := MkLbl(Card, '', 16, 228, FW - 80, 22, 11);
  lblLoginErr.FontColor := CLR_RED;
  lblLoginErr.TextSettings.HorzAlign := TTextAlign.Center;

  { ════════════════════════════════════════════════════
    DASHBOARD
    ════════════════════════════════════════════════════ }
  AddBg(tiDashboard);
  { Avatar krug gore-levo }
  with TRectangle.Create(Self) do
  begin
    Parent := tiDashboard;
    Position.X := 12; Position.Y := 12;
    Width := 38; Height := 38;
    Fill.Kind := TBrushKind.None;
    Stroke.Kind := TBrushKind.None;
    HitTest := True;
    OnClick := btnAvatarDashClick;
  end;
  with TCircle.Create(Self) do
  begin
    Parent := tiDashboard;
    Position.X := 12; Position.Y := 12;
    Width := 38; Height := 38;
    Fill.Color := CLR_CARD2; Fill.Kind := TBrushKind.Solid;
    Stroke.Color := CLR_BRIGHT; Stroke.Kind := TBrushKind.Solid;
    Stroke.Thickness := 2; HitTest := False;
  end;
  imgAvatarDash := TImage.Create(Self);
  imgAvatarDash.Parent := tiDashboard;
  imgAvatarDash.Position.X := 15; imgAvatarDash.Position.Y := 15;
  imgAvatarDash.Width := 32; imgAvatarDash.Height := 32;
  imgAvatarDash.WrapMode := TImageWrapMode.Fit;
  imgAvatarDash.HitTest := False;
  MkLbl(tiDashboard, 'AquaOdrzavanje', 58, 20, 240, 34, 18, True);
  btnRefreshDash := MkBtn(tiDashboard, 'Osv', FW - 66, 22, 50, 30, CLR_CARD2);
  btnRefreshDash.OnClick := btnRefreshDashClick;
  sbDash := MkScroll(tiDashboard, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiDashboard, 0);

  { ════════════════════════════════════════════════════
    REGISTER
    ════════════════════════════════════════════════════ }
  AddBg(tiRegister);
  RegCard := MkRect(tiRegister, 24, FH * 0.18, FW - 48, 360, $CC0D2444, 22);
  MkLbl(tiRegister, 'Registracija', 0, FH * 0.08, FW, 36, 20, True)
    .TextSettings.HorzAlign := TTextAlign.Center;
  MkLbl(RegCard, 'ID zaposlenog', 20, 16, CW - 8, 20, 12);
  edtRegEmpID    := MkEdit(RegCard, 'npr. EMP-001', 20, 36, CW - 8);
  MkLbl(RegCard, 'Korisnicko ime', 20, 86, CW - 8, 20, 12);
  edtRegUsername := MkEdit(RegCard, 'Unesite korisnicko ime', 20, 106, CW - 8);
  MkLbl(RegCard, 'Lozinka', 20, 156, CW - 8, 20, 12);
  edtRegPass     := MkEdit(RegCard, 'Unesite lozinku', 20, 176, CW - 8, True);
  MkLbl(RegCard, 'Potvrdite lozinku', 20, 226, CW - 8, 20, 12);
  edtRegPass2    := MkEdit(RegCard, 'Ponovite lozinku', 20, 246, CW - 8, True);
  lblRegErr := MkLbl(RegCard, '', 20, 296, CW - 8, 22, 11);
  lblRegErr.FontColor := CLR_RED;
  MkBtn(RegCard, 'Registruj se', 20, 326, (CW / 2) - 18, 44, CLR_BRIGHT).OnClick := btnRegisterClick;
  MkBtn(RegCard, '< Nazad', (CW / 2) + 10, 326, (CW / 2) - 18, 44, CLR_CARD2).OnClick := btnBackToLoginClick;

  { ════════════════════════════════════════════════════
    MERENJA VODE
    ════════════════════════════════════════════════════ }
  AddBg(tiMerenje);
  MkLbl(tiMerenje, 'Merenja Vode', 16, 20, 200, 30, 17, True);
  btnNovoMerenje := MkBtn(tiMerenje, '+  Novo merenje', FW - 176, 16, 160, 38, CLR_BRIGHT);
  btnNovoMerenje.OnClick := btnNovoMerenjeClick;

  { Gornja polovina - 3 najnovija merenja }
  MkLbl(tiMerenje, 'Najnovija merenja', 16, 62, 200, 18, 10).FontColor := CLR_DIM;
  sbMerenjaTop := MkScroll(tiMerenje, 0, 82, FW, (FH - 82 - NB) div 2);

  { Separator }
  MkRect(tiMerenje, 16, 82 + (FH - 82 - NB) div 2 + 2, FW - 32, 1, $FF1E3A5F);

  { Donja polovina - lista bazena }
  MkLbl(tiMerenje, 'Istorija po bazenu', 16, 82 + (FH - 82 - NB) div 2 + 10, 200, 18, 10).FontColor := CLR_DIM;
  sbMerenjaBazeni := MkScroll(tiMerenje, 0, 82 + (FH - 82 - NB) div 2 + 28, FW,
    (FH - 82 - NB) div 2 - 28);

  { Kompatibilnost - sbMerenja = sbMerenjaTop }
  sbMerenja := sbMerenjaTop;

  AddNavBar(tiMerenje, 1);

  { Detail tab - istorija za jedan bazen }
  AddBg(tiMerenjeDetail);
  { Nazad - strelica slika, isto kao u profilu }
  with TRectangle.Create(Self) do
  begin
    Parent := tiMerenjeDetail;
    Position.X := 12; Position.Y := 14;
    Width := 44; Height := 44;
    XRadius := 12; YRadius := 12;
    Fill.Color := CLR_CARD2; Fill.Kind := TBrushKind.Solid;
    Stroke.Kind := TBrushKind.None;
    HitTest := True; OnClick := btnBackMerenjeDetClick;
  end;
  with TImage.Create(Self) do
  begin
    Parent := tiMerenjeDetail;
    Position.X := 18; Position.Y := 20;
    Width := 32; Height := 32;
    WrapMode := TImageWrapMode.Fit;
    HitTest := False;
    Bitmap.LoadFromStream(
      TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(BACK_ARROW_B64))
    );
  end;
  lblMerenjeDetTitle := MkLbl(tiMerenjeDetail, '', 100, 20, FW - 116, 28, 14, True);
  sbMerenjaDetail := MkScroll(tiMerenjeDetail, 0, 58, FW, FH - 58 - NB);
  AddNavBar(tiMerenjeDetail, 1);

  { Merenje forma }
  AddBg(tiMerenjeForm);
  MkLbl(tiMerenjeForm, 'Novo Merenje', 16, 20, 300, 30, 17, True);
  Y := 64;
  MkLbl(tiMerenjeForm, 'Bazen *', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbMerBazen := MkCombo(tiMerenjeForm, 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'pH vrednost (6.8 - 7.6)', 16, Y, 250, 20, 12); Y := Y + 22;
  edtMerPH := MkEdit(tiMerenjeForm, 'npr. 7.2', 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'Hlor mg/L (0.5 - 2.0)', 16, Y, 250, 20, 12); Y := Y + 22;
  edtMerHlor := MkEdit(tiMerenjeForm, 'npr. 1.0', 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'Temperatura °C', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMerTemp := MkEdit(tiMerenjeForm, 'npr. 27.0', 16, Y, CW); Y := Y + 50;
  MkLbl(tiMerenjeForm, 'Uneo', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMerUneo := MkEdit(tiMerenjeForm, 'Ime i prezime', 16, Y, CW); Y := Y + 56;
  lblMerErr := MkLbl(tiMerenjeForm, '', 16, Y, CW, 22, 11);
  lblMerErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(tiMerenjeForm, 'Sacuvaj merenje', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveMerenjeClick;
  MkBtn(tiMerenjeForm, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelMerenjeClick;

  { ════════════════════════════════════════════════════
    RADNI NALOZI
    ════════════════════════════════════════════════════ }
  AddBg(tiNalozi);
  MkLbl(tiNalozi, 'Radni Nalozi', 16, 20, 250, 30, 17, True);
  btnNoviNalog := MkBtn(tiNalozi, '+ Nov', FW - 100, 18, 84, 34, CLR_BRIGHT);
  btnNoviNalog.OnClick := btnNoviNalogClick;
  cmbNalogFilter := MkCombo(tiNalozi, 16, 60, CW);
  cmbNalogFilter.Items.AddStrings(['Svi nalozi', 'Otvoren', 'U radu', 'Zatvoren', 'Hitno']);
  cmbNalogFilter.Text := 'Svi nalozi';
  cmbNalogFilter.OnChange := cmbNalogFilterChange;
  sbNalozi := MkScroll(tiNalozi, 0, 110, FW, FH - 110 - NB);
  AddNavBar(tiNalozi, 2);

  { Nalog forma }
  AddBg(tiNalogForm);
  NalogScroll := MkScroll(tiNalogForm, 0, 0, FW, FH - 30);
  MkLbl(NalogScroll.Content, 'Novi Radni Nalog', 16, 16, 350, 30, 16, True);
  Y := 56;
  MkLbl(NalogScroll.Content, 'Tip intervencije *', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogTip := MkCombo(NalogScroll.Content, 16, Y, CW);
  cmbNalogTip.Items.AddStrings(['Preventivno', 'Korektivno', 'Hitno']); Y := Y + 48;
  MkLbl(NalogScroll.Content, 'Kategorija', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogKat := MkCombo(NalogScroll.Content, 16, Y, CW);
  cmbNalogKat.Items.AddStrings(['Servis pumpe', 'Kvalitet vode', 'Filter sistem',
    'Osvetljenje', 'Kvar opreme', 'Ciscenje', 'Ostalo']); Y := Y + 48;
  MkLbl(NalogScroll.Content, 'Prioritet *', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogPrior := MkCombo(NalogScroll.Content, 16, Y, CW);
  cmbNalogPrior.Items.AddStrings(['1 - Hitno', '2 - Visok', '3 - Normalan']); Y := Y + 48;
  MkLbl(NalogScroll.Content, 'Bazen / lokacija', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogBazen := MkCombo(NalogScroll.Content, 16, Y, CW); Y := Y + 48;
  MkLbl(NalogScroll.Content, 'Oprema', 16, Y, 250, 20, 12); Y := Y + 22;
  cmbNalogOprema := MkCombo(NalogScroll.Content, 16, Y, CW); Y := Y + 48;
  MkLbl(NalogScroll.Content, 'Izvrsio / zaduzeni tehnicar', 16, Y, 300, 20, 12); Y := Y + 22;
  edtNalogIzvrsio := MkEdit(NalogScroll.Content, 'Ime tehnicara', 16, Y, CW); Y := Y + 48;
  MkLbl(NalogScroll.Content, 'Opis radova *', 16, Y, 250, 20, 12); Y := Y + 22;
  memoNalogOpis := MkMemo(NalogScroll.Content, 16, Y, CW, 80); Y := Y + 88;
  chkBlokiraj := MkCheck(NalogScroll.Content, 'Blokirati rezervacije za ovaj bazen', 16, Y, CW, 32); Y := Y + 40;
  { Rezervni delovi za novi nalog }
  MkRect(NalogScroll.Content, 16, Y, 388, 1, $FF1E3A5F); Y := Y + 8;
  MkLbl(NalogScroll.Content, 'Rezervni delovi', 16, Y, 250, 20, 12, True); Y := Y + 26;

  { Lista dodatih delova }
  sbDelNewList := MkScroll(NalogScroll.Content, 16, Y, 388, 80);
  sbDelNewList.ShowScrollBars := False;
  Y := Y + 88;

  MkBtn(NalogScroll.Content, '+ Dodaj rezervni deo', 16, Y, CW, 38, CLR_CARD2).OnClick := btnAddDelNalogNewClick;
  Y := Y + 46;

  { Mini-forma za unos dela (skrivena) }
  pnlDelNewForm := MkRect(NalogScroll.Content, 16, Y, 388, 148, $FF0D2A4A, 12);
  pnlDelNewForm.Visible := False;
  MkLbl(pnlDelNewForm, 'Materijal / deo *', 10, 8, 340, 18, 10).FontColor := CLR_DIM;
  cmbDelNewMat := MkCombo(pnlDelNewForm, 10, 26, 368);
  MkLbl(pnlDelNewForm, 'Kolicina', 10, 74, 100, 18, 10).FontColor := CLR_DIM;
  edtDelNewKol := MkEdit(pnlDelNewForm, '1', 10, 92, 120);
  lblDelNewErr := MkLbl(pnlDelNewForm, '', 10, 118, 368, 18, 10);
  lblDelNewErr.FontColor := CLR_RED;
  MkBtn(pnlDelNewForm, 'Sacuvaj', 200, 92, 178, 36, CLR_GREEN).OnClick := btnSnimiDelNalogNewClick;
  MkBtn(pnlDelNewForm, 'Otkazi', 10, 118, 120, 28, CLR_CARD2).OnClick := btnOtkaziDelNalogNewClick;
  Y := Y + 156;

  { Foto za novi nalog }
  MkLbl(NalogScroll.Content, 'Fotografija (opcionalno)', 16, Y, 300, 20, 12); Y := Y + 22;
  imgFotoNalogNew := TImage.Create(Self);
  imgFotoNalogNew.Parent := NalogScroll.Content;
  imgFotoNalogNew.Position.X := 16; imgFotoNalogNew.Position.Y := Y;
  imgFotoNalogNew.Width := 180; imgFotoNalogNew.Height := 135;
  imgFotoNalogNew.WrapMode := TImageWrapMode.Fit;
  with MkRect(NalogScroll.Content, 16, Y, 180, 135, CLR_CARD2, 8) do
  begin
    Stroke.Color := $FF1E3A5F; Stroke.Kind := TBrushKind.Solid;
  end;
  imgFotoNalogNew.BringToFront;
  MkBtn(NalogScroll.Content, '+ Dodaj foto', 204, Y + 46, 172, 38, CLR_CARD2).OnClick := btnAddFotoNalogNewClick;
  Y := Y + 144;
  lblNalogErr := MkLbl(NalogScroll.Content, '', 16, Y, CW, 22, 11);
  lblNalogErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(NalogScroll.Content, 'Otvori nalog', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveNalogClick;
  MkBtn(NalogScroll.Content, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelNalogClick;
  { Padding na dnu da scroll moze da dosegne dugmad }
  with TRectangle.Create(Self) do
  begin
    Parent := NalogScroll.Content;
    Position.X := 0; Position.Y := Y + 120;
    Width := 1; Height := 1;
    Fill.Kind := TBrushKind.None;
    Stroke.Kind := TBrushKind.None;
    HitTest := False;
  end;

  { Nalog detalji — scroll za ceo ekran }
  AddBg(tiNalogDetail);
  lblNalogDetTitle := MkLbl(tiNalogDetail, 'Radni Nalog', 16, 16, 300, 30, 16, True);
  sbNalogDetail := MkScroll(tiNalogDetail, 0, 56, FW, FH - 56 - 110);
  btnZatvoriNalog := MkBtn(tiNalogDetail, 'Zatvori nalog', 16, FH - 104, (CW / 2) - 8, 44, CLR_GREEN);
  btnZatvoriNalog.OnClick := btnZatvoriNalogClick;
  MkBtn(tiNalogDetail, '< Nazad', (CW / 2) + 24, FH - 104, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnBackNalogClick;

  { ════════════════════════════════════════════════════
    OPREMA
    ════════════════════════════════════════════════════ }
  AddBg(tiOprema);
  MkLbl(tiOprema, 'Oprema', 16, 20, 250, 30, 17, True);
  btnNovaOprema := MkBtn(tiOprema, '+ Nova', FW - 100, 18, 84, 34, CLR_BRIGHT);
  btnNovaOprema.OnClick := btnNovaOpremaClick;
  sbOprema := MkScroll(tiOprema, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiOprema, 3);

  { Oprema forma — NalogScroll stil }
  AddBg(tiOpremaForm);
  with MkScroll(tiOpremaForm, 0, 0, FW, FH - 30) do
  begin
    MkLbl(Content, 'Nova Oprema', 16, 16, 300, 30, 16, True);
    Y := 56;
    MkLbl(Content, 'Naziv *', 16, Y, 200, 20, 12); Y := Y + 22;
    edtOpNaziv := MkEdit(Content, '', 16, Y, CW); Y := Y + 48;
    MkLbl(Content, 'Tip *', 16, Y, 200, 20, 12); Y := Y + 22;
    cmbOpTip := MkCombo(Content, 16, Y, CW);
    cmbOpTip.Items.AddStrings(['Pumpa', 'Filter', 'Dozator', 'Vozilo', 'Senzor',
      'Osvetljenje', 'Grijanije', 'Ostalo']); Y := Y + 48;
    MkLbl(Content, 'Status *', 16, Y, 200, 20, 12); Y := Y + 22;
    cmbOpStatus := MkCombo(Content, 16, Y, CW);
    cmbOpStatus.Items.AddStrings(['Aktivna', 'Neaktivna', 'Na popravci', 'Penzionisana']); Y := Y + 48;
    MkLbl(Content, 'Bazen / lokacija', 16, Y, 200, 20, 12); Y := Y + 22;
    cmbOpBazen := MkCombo(Content, 16, Y, CW); Y := Y + 48;
    MkLbl(Content, 'Model', 16, Y, 200, 20, 12); Y := Y + 22;
    edtOpModel := MkEdit(Content, '', 16, Y, CW); Y := Y + 48;
    MkLbl(Content, 'Serijski broj', 16, Y, 200, 20, 12); Y := Y + 22;
    edtOpSerial := MkEdit(Content, '', 16, Y, CW); Y := Y + 48;
    MkLbl(Content, 'Datum nabavke (GGGG-MM-DD)', 16, Y, 300, 20, 12); Y := Y + 22;
    edtOpDatum := MkEdit(Content, '', 16, Y, CW); Y := Y + 48;
    MkLbl(Content, 'Napomena', 16, Y, 200, 20, 12); Y := Y + 22;
    memoOpNap := MkMemo(Content, 16, Y, CW, 72); Y := Y + 80;
    lblOpErr := MkLbl(Content, '', 16, Y, CW, 22, 11);
    lblOpErr.FontColor := CLR_RED; Y := Y + 28;
    MkBtn(Content, 'Sacuvaj', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveOpremaClick;
    MkBtn(Content, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelOpremaClick;
    { Padding na dnu }
    with TRectangle.Create(Self) do
    begin
      Parent := Content; Position.X := 0; Position.Y := Y + 80;
      Width := 1; Height := 1;
      Fill.Kind := TBrushKind.None; Stroke.Kind := TBrushKind.None; HitTest := False;
    end;
  end;
  { ════════════════════════════════════════════════════
    MAGACIN
    ════════════════════════════════════════════════════ }
  AddBg(tiMagacin);
  MkLbl(tiMagacin, 'Magacin', 16, 20, 250, 30, 17, True);
  btnNoviMat := MkBtn(tiMagacin, '+ Nov', FW - 100, 18, 84, 34, CLR_BRIGHT);
  btnNoviMat.OnClick := btnNoviMatClick;
  sbMagacin := MkScroll(tiMagacin, 0, 64, FW, FH - 64 - NB);
  AddNavBar(tiMagacin, 4);

  { Materijal forma }
  AddBg(tiMatForm);
  MkLbl(tiMatForm, 'Novi Materijal', 16, 16, 300, 30, 16, True);
  Y := 56;
  MkLbl(tiMatForm, 'Naziv *', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMatNaziv := MkEdit(tiMatForm, '', 16, Y, CW); Y := Y + 48;
  MkLbl(tiMatForm, 'Tip', 16, Y, 200, 20, 12); Y := Y + 22;
  cmbMatTip := MkCombo(tiMatForm, 16, Y, CW);
  cmbMatTip.Items.AddStrings(['Hemija', 'Rezervni deo', 'Alat', 'Ostalo']); Y := Y + 48;
  MkLbl(tiMatForm, 'Jedinica mere', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMatJed := MkEdit(tiMatForm, 'kg / kom / L', 16, Y, CW); Y := Y + 48;
  MkLbl(tiMatForm, 'Trenutna zaliha', 16, Y, 200, 20, 12); Y := Y + 22;
  edtMatZal := MkEdit(tiMatForm, '0', 16, Y, CW); Y := Y + 48;
  MkLbl(tiMatForm, 'Minimalna zaliha (alarm)', 16, Y, 280, 20, 12); Y := Y + 22;
  edtMatMin := MkEdit(tiMatForm, '0', 16, Y, CW); Y := Y + 56;
  lblMatErr := MkLbl(tiMatForm, '', 16, Y, CW, 22, 11);
  lblMatErr.FontColor := CLR_RED; Y := Y + 28;
  MkBtn(tiMatForm, 'Sacuvaj', 16, Y, (CW / 2) - 8, 44, CLR_BRIGHT).OnClick := btnSaveMatClick;
  MkBtn(tiMatForm, 'Odustati', (CW / 2) + 24, Y, (CW / 2) - 8, 44, CLR_CARD2).OnClick := btnCancelMatClick;

  { ================================================================
    PROFIL TAB
    ================================================================ }
  { Pozadinska slika - ista kao za ostale tabove }
  with TImage.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := 0; Position.Y := 0;
    Width := FW; Height := FH;
    WrapMode := TImageWrapMode.Stretch;
    HitTest := False;
    if Assigned(BgImg) and Assigned(BgImg.Bitmap) and (BgImg.Bitmap.Width > 0) then
      Bitmap.Assign(BgImg.Bitmap);
  end;
  with TRectangle.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := 0; Position.Y := 0;
    Width := FW; Height := FH;
    Fill.Color := $D0050F1E; Fill.Kind := TBrushKind.Solid;
    Stroke.Kind := TBrushKind.None; HitTest := False;
  end;

  { Nazad - strelica slika }
  with TRectangle.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := 12; Position.Y := 14;
    Width := 44; Height := 44;
    XRadius := 12; YRadius := 12;
    Fill.Color := CLR_CARD2; Fill.Kind := TBrushKind.Solid;
    Stroke.Kind := TBrushKind.None;
    HitTest := True; OnClick := btnBackProfilClick;
  end;
  with TImage.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := 18; Position.Y := 20;
    Width := 32; Height := 32;
    WrapMode := TImageWrapMode.Fit;
    HitTest := False;
    Bitmap.LoadFromStream(
      TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(BACK_ARROW_B64))
    );
  end;

  with TCircle.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := (FW - 100) / 2; Position.Y := 64;
    Width := 100; Height := 100;
    Fill.Color := CLR_CARD2; Fill.Kind := TBrushKind.Solid;
    Stroke.Color := CLR_BRIGHT; Stroke.Kind := TBrushKind.Solid;
    Stroke.Thickness := 3; HitTest := True; OnClick := btnProfilFotoClick;
  end;
  imgProfilBig := TImage.Create(Self);
  imgProfilBig.Parent := tiProfil;
  imgProfilBig.Position.X := (FW - 94) / 2; imgProfilBig.Position.Y := 67;
  imgProfilBig.Width := 94; imgProfilBig.Height := 94;
  imgProfilBig.WrapMode := TImageWrapMode.Fit;
  imgProfilBig.HitTest := True; imgProfilBig.OnClick := btnProfilFotoClick;

  with MkLbl(tiProfil, '+ promeni sliku', 0, 170, FW, 18, 10) do
  begin
    TextSettings.HorzAlign := TTextAlign.Center; FontColor := CLR_DIM;
  end;

  lblProfilIme := MkLbl(tiProfil, '', 0, 196, FW, 34, 22, True);
  lblProfilIme.TextSettings.HorzAlign := TTextAlign.Center;

  lblProfilUloga := MkLbl(tiProfil, '', 0, 234, FW, 22, 13);
  lblProfilUloga.TextSettings.HorzAlign := TTextAlign.Center;
  lblProfilUloga.FontColor := CLR_DIM;

  MkRect(tiProfil, 32, 266, FW - 64, 1, $FF1E3A5F);
  MkRect(tiProfil, 24, 278, FW - 48, 88, CLR_CARD, 14);

  lblProfilDatum := MkLbl(tiProfil, '', 44, 292, FW - 88, 22, 12);
  lblProfilDatum.FontColor := CLR_WHITE;
  lblProfilID := MkLbl(tiProfil, '', 44, 326, FW - 88, 22, 12);
  lblProfilID.FontColor := CLR_WHITE;

  { Logout dugme - slika dole desno }
  with TRectangle.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := FW - 76; Position.Y := FH - 96;
    Width := 56; Height := 56;
    XRadius := 14; YRadius := 14;
    Fill.Color := $FF0D1B2A; Fill.Kind := TBrushKind.Solid;
    Stroke.Kind := TBrushKind.None;
    HitTest := True; OnClick := btnLogoutClick;
  end;
  with TImage.Create(Self) do
  begin
    Parent := tiProfil;
    Position.X := FW - 70; Position.Y := FH - 90;
    Width := 44; Height := 44;
    WrapMode := TImageWrapMode.Fit;
    HitTest := False;
    Bitmap.LoadFromStream(
      TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(LOGOUT_ICON_B64))
    );
  end;
end;

{ ===================================================================
  PROFIL PROCEDURES
  =================================================================== }

procedure TfrmMain.LoadProfilData;
var
  Q: TFDQuery;
  MS: TMemoryStream;
begin
  if not dmData.IsConnected or (FLoggedKoID <= 0) then Exit;
  Q := TFDQuery.Create(nil);
  MS := TMemoryStream.Create;
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT KO_USERNAME, KO_ULOGA, KO_EMP_ID, KO_DATUM, KO_FOTO ' +
      'FROM KORISNIK_ODR WHERE KO_ID = :ID';
    Q.ParamByName('ID').AsInteger := FLoggedKoID;
    Q.Open;
    if not Q.IsEmpty then
    begin
      if Assigned(lblProfilIme) then
        lblProfilIme.Text := Q.FieldByName('KO_USERNAME').AsString;
      if Assigned(lblProfilUloga) then
      begin
        if Trim(Q.FieldByName('KO_ULOGA').AsString) <> '' then
          lblProfilUloga.Text := Q.FieldByName('KO_ULOGA').AsString
        else
          lblProfilUloga.Text := 'Korisnik';
      end;
      if Assigned(lblProfilDatum) then
      begin
        if not Q.FieldByName('KO_DATUM').IsNull then
          lblProfilDatum.Text := 'Radnik od:   ' +
            FormatDateTime('dd.mm.yyyy', Q.FieldByName('KO_DATUM').AsDateTime)
        else
          lblProfilDatum.Text := 'Radnik od:   -';
      end;
      if Assigned(lblProfilID) then
        lblProfilID.Text := 'AdminID:       ' + Q.FieldByName('KO_EMP_ID').AsString;
      if not Q.Fields[4].IsNull then
      begin
        (Q.Fields[4] as TBlobField).SaveToStream(MS);
        MS.Position := 0;
        if Assigned(imgProfilBig) then imgProfilBig.Bitmap.LoadFromStream(MS);
        MS.Position := 0;
        if Assigned(imgAvatarDash) then imgAvatarDash.Bitmap.LoadFromStream(MS);
      end;
    end;
  finally
    Q.Free; MS.Free;
  end;
end;

procedure TfrmMain.btnAvatarDashClick(Sender: TObject);
begin
  FPrevProfilTab := tcMain.ActiveTab;
  LoadProfilData;
  tcMain.ActiveTab := tiProfil;
end;

procedure TfrmMain.btnBackProfilClick(Sender: TObject);
begin
  if Assigned(FPrevProfilTab) then
    tcMain.ActiveTab := FPrevProfilTab
  else
    tcMain.ActiveTab := tiDashboard;
end;

procedure TfrmMain.btnLogoutClick(Sender: TObject);
begin
  FLoggedKoID := 0;
  FLoggedUsername := '';
  if Assigned(imgAvatarDash) then imgAvatarDash.Bitmap.Clear(0);
  if Assigned(imgProfilBig)  then imgProfilBig.Bitmap.Clear(0);
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.btnProfilFotoClick(Sender: TObject);
var
  OD: TOpenDialog;
  MS: TMemoryStream;
  Q: TFDQuery;
begin
  OD := TOpenDialog.Create(nil);
  try
    OD.Filter := 'Slike|*.jpg;*.jpeg;*.png;*.bmp';
    OD.Title := 'Izaberi profilnu fotografiju';
    if OD.Execute then
    begin
      if Assigned(imgProfilBig)  then imgProfilBig.Bitmap.LoadFromFile(OD.FileName);
      if Assigned(imgAvatarDash) then imgAvatarDash.Bitmap.LoadFromFile(OD.FileName);
      if dmData.IsConnected and (FLoggedKoID > 0) then
      begin
        MS := TMemoryStream.Create;
        Q  := TFDQuery.Create(nil);
        try
          MS.LoadFromFile(OD.FileName);
          MS.Position := 0;
          Q.Connection := dmData.Conn;
          Q.SQL.Text := 'UPDATE KORISNIK_ODR SET KO_FOTO=:F WHERE KO_ID=:ID';
          Q.ParamByName('F').LoadFromStream(MS, ftBlob);
          Q.ParamByName('ID').AsInteger := FLoggedKoID;
          Q.ExecSQL;
          dmData.CommitWork;
        finally
          Q.Free; MS.Free;
        end;
      end;
    end;
  finally
    OD.Free;
  end;
end;

procedure TfrmMain.btnAddFotoNalogNewClick(Sender: TObject);
var
  OD: TOpenDialog;
  MS: TMemoryStream;
begin
  OD := TOpenDialog.Create(nil);
  try
    OD.Filter := 'Slike|*.jpg;*.jpeg;*.png;*.bmp';
    OD.Title := 'Izaberi fotografiju za nalog';
    if OD.Execute then
    begin
      if Assigned(imgFotoNalogNew) then
        imgFotoNalogNew.Bitmap.LoadFromFile(OD.FileName);
      MS := TMemoryStream.Create;
      try
        MS.LoadFromFile(OD.FileName);
        SetLength(FFotoNewData, MS.Size);
        MS.Position := 0;
        MS.ReadBuffer(FFotoNewData[0], MS.Size);
      finally
        MS.Free;
      end;
    end;
  finally
    OD.Free;
  end;
end;

procedure TfrmMain.btnAddDelNalogNewClick(Sender: TObject);
var
  Q: TFDQuery;
  I: Integer;
begin
  { Popuni combo materijala }
  cmbDelNewMat.Items.Clear;
  SetLength(FDelNewMatIDs, 0);
  if dmData.IsConnected then
  begin
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := dmData.Conn;
      Q.SQL.Text := 'SELECT MAT_ID, MAT_NAZIV, MAT_ZALIHA, MAT_JEDINICA FROM MATERIJAL WHERE MAT_ZALIHA > 0 ORDER BY MAT_NAZIV';
      Q.Open;
      while not Q.Eof do
      begin
        cmbDelNewMat.Items.Add(
          Q.FieldByName('MAT_NAZIV').AsString + '  (zal: ' +
          Format('%.1f', [Q.FieldByName('MAT_ZALIHA').AsFloat]) + ' ' +
          Q.FieldByName('MAT_JEDINICA').AsString + ')');
        SetLength(FDelNewMatIDs, Length(FDelNewMatIDs) + 1);
        FDelNewMatIDs[High(FDelNewMatIDs)] := Q.FieldByName('MAT_ID').AsInteger;
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  end;
  edtDelNewKol.Text := '1';
  lblDelNewErr.Text := '';
  pnlDelNewForm.Visible := True;
end;

procedure TfrmMain.btnSnimiDelNalogNewClick(Sender: TObject);
var
  Kol: Double;
  N: Integer;
begin
  lblDelNewErr.Text := '';
  if cmbDelNewMat.ItemIndex < 0 then
  begin lblDelNewErr.Text := 'Izaberite materijal.'; Exit; end;
  if not TryStrToFloat(edtDelNewKol.Text, Kol) or (Kol <= 0) then
  begin lblDelNewErr.Text := 'Unesite ispravnu kolicinu.'; Exit; end;

  { Dodaj u privremenu listu }
  N := Length(FNewNalogDelovi);
  SetLength(FNewNalogDelovi, N + 1);
  FNewNalogDelovi[N].MatID := FDelNewMatIDs[cmbDelNewMat.ItemIndex];
  FNewNalogDelovi[N].Kol   := Kol;
  FNewNalogDelovi[N].Naziv := cmbDelNewMat.Items[cmbDelNewMat.ItemIndex];

  { Prikazi u listi }
  with MkLbl(sbDelNewList.Content, '- ' + FNewNalogDelovi[N].Naziv +
    '  x' + Format('%.1f', [Kol]),
    4, N * 22, 380, 20, 10) do
    FontColor := CLR_WHITE;

  pnlDelNewForm.Visible := False;
end;

procedure TfrmMain.btnOtkaziDelNalogNewClick(Sender: TObject);
begin
  pnlDelNewForm.Visible := False;
end;

procedure TfrmMain.btnBackMerenjeDetClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMerenje;
end;

procedure TfrmMain.BazenMerenjeCardClick(Sender: TObject);
var
  ID: Integer;
  Naziv: string;
begin
  ID := TControl(Sender).Tag;
  Naziv := TCornerButton(Sender).Text;
  LoadMerenjaZaBazen(ID, Naziv);
end;

procedure TfrmMain.LoadMerenjaZaBazen(ABazenID: Integer; const ABazenNaziv: string);
var
  Q: TFDQuery;
  Y: Single;
  I: Integer;
begin
  { Ocisti detail scroll }
  for I := sbMerenjaDetail.Content.ChildrenCount - 1 downto 0 do
    sbMerenjaDetail.Content.Children[I].Parent := nil;

  if Assigned(lblMerenjeDetTitle) then
    lblMerenjeDetTitle.Text := ABazenNaziv;

  tcMain.ActiveTab := tiMerenjeDetail;

  if not dmData.IsConnected then Exit;

  Y := 8;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT MV_ID, MV_DATUM, MV_PH, MV_HLOR, MV_TEMP, MV_ALARM ' +
      'FROM MERENJE_VODE WHERE MV_BAZEN_ID=:BID ORDER BY MV_DATUM DESC';
    Q.ParamByName('BID').AsInteger := ABazenID;
    Q.Open;
    while not Q.Eof do
    begin
      AddMerenjeCard(
        Q.FieldByName('MV_ID').AsInteger,
        ABazenNaziv,
        FormatDateTime('dd.mm.yyyy  hh:nn', Q.FieldByName('MV_DATUM').AsDateTime),
        Q.FieldByName('MV_PH').AsFloat,
        Q.FieldByName('MV_HLOR').AsFloat,
        Q.FieldByName('MV_TEMP').AsFloat,
        Q.FieldByName('MV_ALARM').AsString = 'Y',
        Y,
        sbMerenjaDetail
      );
      Q.Next;
    end;
    if Y = 8 then
      MkLbl(sbMerenjaDetail.Content, 'Nema merenja za ovaj bazen.', 16, 16, 388, 24, 13)
        .FontColor := CLR_DIM;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.AddAlarmCard(AParent: TFmxObject; const AText, ASub: string;
  AColor: TAlphaColor; var AY: Single);
var C: TRectangle; L: TLabel;
begin
  C := MkRect(AParent, 16, AY, 388, 70, AColor, 14);
  MkLbl(C, AText, 14, 8, 340, 24, 13, True);
  L := MkLbl(C, ASub, 14, 34, 340, 20, 11);
  L.FontColor := $FFDDDDDD;
  AY := AY + 78;
end;

procedure TfrmMain.AddMerenjeCard(AID: Integer; const ABazen, ADatum: string;
  APH, AHlor, ATemp: Double; AAlarm: Boolean; var AY: Single;
  AScroll: TScrollBox = nil);
var
  C: TRectangle;
  Color: TAlphaColor;
  Info: string;
  lDate, lA: TLabel;
  TargetScroll: TScrollBox;
begin
  TargetScroll := AScroll;
  if not Assigned(TargetScroll) then TargetScroll := sbMerenja;
  if AAlarm then Color := $FF8B1A1A else Color := CLR_CARD;
  C := MkRect(TargetScroll.Content, 16, AY, 388, 80, Color, 14);
  C.Tag := AID;
  C.HitTest := True;
  C.OnClick := MerenjeCardClick;
  MkLbl(C, ABazen, 14, 6, 280, 22, 13, True);
  lDate := MkLbl(C, ADatum, 14, 28, 280, 18, 11);
  lDate.FontColor := CLR_DIM;
  Info := Format('pH: %.1f  |  Hlor: %.2f  |  T: %.1f°C', [APH, AHlor, ATemp]);
  MkLbl(C, Info, 14, 50, 340, 20, 12);
  if AAlarm then
  begin
    lA := MkLbl(C, '! ALARM', 300, 6, 80, 22, 11, True);
    lA.FontColor := CLR_YELLOW;
  end;
  AY := AY + 88;
end;

procedure TfrmMain.AddNalogCard(AID: Integer; const ATip, AOpis, AStatus, ADatum: string;
  APrior: Integer; var AY: Single);
var
  C: TRectangle;
  PriorColor, StatColor: TAlphaColor;
  PriorText: string;
  lPrior, lStat, lDatum, lOpis: TLabel;
begin
  if APrior = 1 then begin PriorColor := CLR_RED;    PriorText := 'HITNO'; end
  else if APrior = 2 then begin PriorColor := CLR_ORANGE; PriorText := 'Visok'; end
  else begin PriorColor := CLR_BLUE; PriorText := 'Normal'; end;

  if AStatus = 'Zatvoren' then StatColor := CLR_GREEN
  else if AStatus = 'U radu' then StatColor := CLR_BLUE
  else StatColor := CLR_ORANGE;

  C := MkRect(sbNalozi.Content, 16, AY, 388, 96, CLR_CARD, 14);
  C.Tag := AID;
  C.HitTest := True;
  C.OnClick := NalogCardClick;

  lPrior := MkLbl(C, PriorText, 14, 6, 160, 20, 11, True);
  lPrior.FontColor := PriorColor;
  lStat := MkLbl(C, AStatus, 234, 6, 140, 20, 11, True);
  lStat.FontColor := StatColor;
  lStat.TextSettings.HorzAlign := TTextAlign.Trailing;
  MkLbl(C, ATip, 14, 28, 200, 22, 13, True);
  lDatum := MkLbl(C, ADatum, 14, 52, 340, 18, 10);
  lDatum.FontColor := CLR_DIM;
  lOpis := MkLbl(C, AOpis, 14, 70, 356, 18, 10);
  lOpis.FontColor := CLR_DIM;
  MkLbl(C, '>', 362, 32, 20, 30, 20).FontColor := CLR_DIM;
  AY := AY + 104;
end;

procedure TfrmMain.AddOpremaCard(AID: Integer; const ANaziv, ATip, AStatus, AModel, ASerial, ADatum: string;
  var AY: Single);
var
  C: TRectangle;
  DotColor: TAlphaColor;
  Dot: TCircle;
  lSub, lDet: TLabel;
  Det: string;
begin
  if AStatus = 'Aktivna' then DotColor := CLR_GREEN
  else if AStatus = 'Na popravci' then DotColor := CLR_ORANGE
  else DotColor := $FF9E9E9E;

  C := MkRect(sbOprema.Content, 16, AY, 388, 90, CLR_CARD, 14);
  C.Tag := AID;
  C.HitTest := True;
  C.OnClick := OpremaCardClick;

  Dot := TCircle.Create(Self);
  Dot.Parent := C;
  Dot.Position.X := 16; Dot.Position.Y := 22;
  Dot.Width := 14; Dot.Height := 14;
  Dot.Fill.Color := DotColor;
  Dot.Fill.Kind := TBrushKind.Solid;
  Dot.Stroke.Kind := TBrushKind.None;

  MkLbl(C, ANaziv, 40, 8, 300, 22, 13, True);
  lSub := MkLbl(C, ATip + ' · ' + AStatus, 40, 30, 300, 18, 11);
  lSub.FontColor := CLR_DIM;

  { Detalji — model, serijski, datum }
  Det := '';
  if AModel <> '' then Det := 'Model: ' + AModel;
  if ASerial <> '' then
  begin
    if Det <> '' then Det := Det + '   ';
    Det := Det + 'S/N: ' + ASerial;
  end;
  if ADatum <> '' then
  begin
    if Det <> '' then Det := Det + '   ';
    Det := Det + 'Nab: ' + ADatum;
  end;
  if Det <> '' then
  begin
    lDet := MkLbl(C, Det, 40, 52, 336, 18, 10);
    lDet.FontColor := $FF607D8B;
  end;

  MkLbl(C, '>', 362, 32, 20, 30, 18).FontColor := CLR_DIM;
  AY := AY + 98;
end;

procedure TfrmMain.AddMatCard(AID: Integer; const ANaziv, ATip: string;
  AZal, AMin: Double; var AY: Single);
var
  C: TRectangle;
  Low: Boolean;
  lTip, lZal, lW: TLabel;
begin
  Low := AZal <= AMin;
  C := MkRect(sbMagacin.Content, 16, AY, 388, 72, CLR_CARD, 14);
  C.Tag := AID;
  MkLbl(C, ANaziv, 14, 6, 280, 22, 13, True);
  lTip := MkLbl(C, ATip, 14, 28, 200, 18, 11);
  lTip.FontColor := CLR_DIM;
  lZal := MkLbl(C, Format('Zaliha: %.1f', [AZal]), 14, 48, 200, 18, 12);
  if Low then lZal.FontColor := CLR_RED
  else lZal.FontColor := CLR_GREEN;
  if Low then
  begin
    lW := MkLbl(C, '! Niska zaliha', 240, 48, 140, 18, 11, True);
    lW.FontColor := CLR_ORANGE;
  end;
  AY := AY + 80;
end;

{ ===================================================================
  LOAD DATA
  =================================================================== }

procedure TfrmMain.LoadBazenCombo(ACombo: TComboEdit);
var Q: TFDQuery;
begin
  ACombo.Items.Clear;
  ACombo.Items.Add('(nije vezano)');
  SetLength(FBazenIDs, 1);
  FBazenIDs[0] := -1;

  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT B_ID, B_NAZIV FROM BAZEN ORDER BY B_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      ACombo.Items.Add(Q.FieldByName('B_NAZIV').AsString);
      SetLength(FBazenIDs, Length(FBazenIDs) + 1);
      FBazenIDs[High(FBazenIDs)] := Q.FieldByName('B_ID').AsInteger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadOpremaCombo;
var Q: TFDQuery;
begin
  cmbNalogOprema.Items.Clear;
  cmbNalogOprema.Items.Add('(nije vezano)');
  SetLength(FOpremaIDs, 1);
  FOpremaIDs[0] := -1;

  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT OP_ID, OP_NAZIV FROM OPREMA ORDER BY OP_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      cmbNalogOprema.Items.Add(Q.FieldByName('OP_NAZIV').AsString);
      SetLength(FOpremaIDs, Length(FOpremaIDs) + 1);
      FOpremaIDs[High(FOpremaIDs)] := Q.FieldByName('OP_ID').AsInteger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.RefreshDashboard;
var
  Q: TFDQuery;
  Y: Single;
  I: Integer;
  KPIBg: TRectangle;
  Tot, Otv, Hit, Ala: Integer;
  lOtv, lHit, lAla: TLabel;
begin
  if not dmData.IsConnected then Exit;

  for I := sbDash.Content.ChildrenCount - 1 downto 0 do
    sbDash.Content.Children[I].Parent := nil;

  Y := 8;

  { KPI row }
  KPIBg := MkRect(sbDash.Content, 16, Y, 388, 80, CLR_CARD2, 16); Y := Y + 88;
  Tot := dmData.ExecScalar('SELECT COUNT(*) FROM RADNI_NALOG');
  Otv := dmData.ExecScalar('SELECT COUNT(*) FROM RADNI_NALOG WHERE RN_STATUS <> ''Zatvoren''');
  Hit := dmData.ExecScalar('SELECT COUNT(*) FROM RADNI_NALOG WHERE RN_TIP=''Hitno'' AND RN_STATUS <> ''Zatvoren''');
  Ala := dmData.ExecScalar('SELECT COUNT(*) FROM MERENJE_VODE WHERE MV_ALARM=''Y''');

  MkLbl(KPIBg, 'Ukupno naloga', 10, 8, 90, 18, 9).FontColor := CLR_DIM;
  MkLbl(KPIBg, IntToStr(Tot), 10, 26, 90, 36, 22, True);
  MkLbl(KPIBg, 'Otvoreno', 108, 8, 80, 18, 9).FontColor := CLR_DIM;
  lOtv := MkLbl(KPIBg, IntToStr(Otv), 108, 26, 80, 36, 22, True);
  if Otv > 0 then lOtv.FontColor := CLR_ORANGE;
  MkLbl(KPIBg, 'Hitno', 206, 8, 70, 18, 9).FontColor := CLR_DIM;
  lHit := MkLbl(KPIBg, IntToStr(Hit), 206, 26, 70, 36, 22, True);
  if Hit > 0 then lHit.FontColor := CLR_RED;
  MkLbl(KPIBg, 'Alarmi', 294, 8, 80, 18, 9).FontColor := CLR_DIM;
  lAla := MkLbl(KPIBg, IntToStr(Ala), 294, 26, 80, 36, 22, True);
  if Ala > 0 then lAla.FontColor := CLR_YELLOW;

  { Alarmi }
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT M.MV_DATUM, B.B_NAZIV, M.MV_PH, M.MV_HLOR, M.MV_NAPOMENA ' +
      'FROM MERENJE_VODE M JOIN BAZEN B ON B.B_ID=M.MV_BAZEN_ID ' +
      'WHERE M.MV_ALARM=''Y'' ORDER BY M.MV_DATUM DESC';
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbDash.Content, '[!] Aktivni Alarmi', 16, Y, 300, 22, 12, True)
        .FontColor := CLR_YELLOW;
      Y := Y + 28;
      while not Q.Eof do
      begin
        AddAlarmCard(sbDash.Content,
          Q.FieldByName('B_NAZIV').AsString + ' — pH: ' +
          Q.FieldByName('MV_PH').AsString + '  Hlor: ' + Q.FieldByName('MV_HLOR').AsString,
          Q.FieldByName('MV_DATUM').AsString + '  ' + Q.FieldByName('MV_NAPOMENA').AsString,
          $FF8B1A1A, Y);
        Q.Next;
      end;
    end;
    Q.Close;

    { Hitni nalozi }
    Q.SQL.Text :=
      'SELECT RN_ID, RN_TIP, RN_OPIS, RN_STATUS, RN_DATUM_OTVAR ' +
      'FROM RADNI_NALOG WHERE RN_PRIORITET=1 AND RN_STATUS <> ''Zatvoren'' ' +
      'ORDER BY RN_DATUM_OTVAR DESC';
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbDash.Content, '[ ! ] Hitni Nalozi', 16, Y, 300, 22, 12, True)
        .FontColor := CLR_RED;
      Y := Y + 28;
      while not Q.Eof do
      begin
        AddAlarmCard(sbDash.Content,
          Q.FieldByName('RN_TIP').AsString + ' — ' + Q.FieldByName('RN_STATUS').AsString,
          Q.FieldByName('RN_OPIS').AsString,
          $FF4A0A0A, Y);
        Q.Next;
      end;
    end;
    Q.Close;

    { Blokirani bazeni }
    Q.SQL.Text :=
      'SELECT DISTINCT B.B_NAZIV FROM RADNI_NALOG R ' +
      'JOIN BAZEN B ON B.B_ID=R.RN_BAZEN_ID ' +
      'WHERE R.RN_BLOKIRA_REZ=''Y'' AND R.RN_STATUS <> ''Zatvoren''';
    Q.Open;
    if not Q.IsEmpty then
    begin
      MkLbl(sbDash.Content, '[ x ] Blokirani Bazeni', 16, Y, 300, 22, 12, True)
        .FontColor := CLR_ORANGE;
      Y := Y + 28;
      while not Q.Eof do
      begin
        AddAlarmCard(sbDash.Content,
          Q.FieldByName('B_NAZIV').AsString,
          'Rezervacije onemogucene zbog aktivnog naloga',
          $FF3A2500, Y);
        Q.Next;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadMerenja;
var
  Q: TFDQuery;
  Y: Single;
  I: Integer;
  BtnBazen: TCornerButton;
begin
  { Ocisti top scroll }
  for I := sbMerenjaTop.Content.ChildrenCount - 1 downto 0 do
    sbMerenjaTop.Content.Children[I].Parent := nil;
  { Ocisti bazeni scroll }
  for I := sbMerenjaBazeni.Content.ChildrenCount - 1 downto 0 do
    sbMerenjaBazeni.Content.Children[I].Parent := nil;

  if not dmData.IsConnected then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;

    { Gornja polovina - 3 najnovija merenja }
    Y := 8;
    Q.SQL.Text :=
      'SELECT FIRST 3 M.MV_ID, B.B_NAZIV, M.MV_DATUM, M.MV_PH, M.MV_HLOR, M.MV_TEMP, M.MV_ALARM ' +
      'FROM MERENJE_VODE M JOIN BAZEN B ON B.B_ID=M.MV_BAZEN_ID ' +
      'ORDER BY M.MV_DATUM DESC';
    Q.Open;
    while not Q.Eof do
    begin
      AddMerenjeCard(
        Q.FieldByName('MV_ID').AsInteger,
        Q.FieldByName('B_NAZIV').AsString,
        FormatDateTime('dd.mm.yyyy  hh:nn', Q.FieldByName('MV_DATUM').AsDateTime),
        Q.FieldByName('MV_PH').AsFloat,
        Q.FieldByName('MV_HLOR').AsFloat,
        Q.FieldByName('MV_TEMP').AsFloat,
        Q.FieldByName('MV_ALARM').AsString = 'Y',
        Y,
        sbMerenjaTop
      );
      Q.Next;
    end;
    Q.Close;

    { Donja polovina - lista bazena }
    Y := 8;
    Q.SQL.Text := 'SELECT B_ID, B_NAZIV FROM BAZEN ORDER BY B_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      BtnBazen := TCornerButton.Create(Self);
      BtnBazen.Parent := sbMerenjaBazeni.Content;
      BtnBazen.Position.X := 16;
      BtnBazen.Position.Y := Y;
      BtnBazen.Width := 388;
      BtnBazen.Height := 44;
      BtnBazen.Text := Q.FieldByName('B_NAZIV').AsString;
      BtnBazen.Tag := Q.FieldByName('B_ID').AsInteger;
      BtnBazen.HitTest := True;
      BtnBazen.OnClick := BazenMerenjeCardClick;
      Y := Y + 52;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadNalozi(const AFilter: string);
var Q: TFDQuery; SQL: string; Y: Single; I: Integer;
begin
  for I := sbNalozi.Content.ChildrenCount - 1 downto 0 do
    sbNalozi.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  SQL := 'SELECT RN_ID, RN_TIP, RN_OPIS, RN_STATUS, RN_PRIORITET, RN_DATUM_OTVAR FROM RADNI_NALOG ';
  if (AFilter <> '') and (AFilter <> 'Svi nalozi') then
  begin
    if AFilter = 'Hitno' then
      SQL := SQL + 'WHERE RN_TIP=''Hitno'' '
    else
      SQL := SQL + 'WHERE RN_STATUS=''' + AFilter + ''' ';
  end;
  SQL := SQL + 'ORDER BY RN_PRIORITET, RN_DATUM_OTVAR DESC';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := SQL;
    Q.Open;
    while not Q.Eof do
    begin
      AddNalogCard(
        Q.FieldByName('RN_ID').AsInteger,
        Q.FieldByName('RN_TIP').AsString,
        Q.FieldByName('RN_OPIS').AsString,
        Q.FieldByName('RN_STATUS').AsString,
        FormatDateTime('dd.mm.yyyy  hh:nn', Q.FieldByName('RN_DATUM_OTVAR').AsDateTime),
        Q.FieldByName('RN_PRIORITET').AsInteger,
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadOprema;
var Q: TFDQuery; Y: Single; I: Integer;
begin
  for I := sbOprema.Content.ChildrenCount - 1 downto 0 do
    sbOprema.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT OP_ID, OP_NAZIV, OP_TIP, OP_STATUS, OP_MODEL, OP_SERIJSKI, OP_DATUM_NABAVKE FROM OPREMA ORDER BY OP_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      AddOpremaCard(
        Q.FieldByName('OP_ID').AsInteger,
        Q.FieldByName('OP_NAZIV').AsString,
        Q.FieldByName('OP_TIP').AsString,
        Q.FieldByName('OP_STATUS').AsString,
        Q.FieldByName('OP_MODEL').AsString,
        Q.FieldByName('OP_SERIJSKI').AsString,
        Q.FieldByName('OP_DATUM_NABAVKE').AsString,
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadMagacin;
var Q: TFDQuery; Y: Single; I: Integer;
begin
  for I := sbMagacin.Content.ChildrenCount - 1 downto 0 do
    sbMagacin.Content.Children[I].Parent := nil;
  if not dmData.IsConnected then Exit;
  Y := 8;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT MAT_ID, MAT_NAZIV, MAT_TIP, MAT_ZALIHA, MAT_MIN_ZAL ' +
      'FROM MATERIJAL ORDER BY MAT_TIP, MAT_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      AddMatCard(
        Q.FieldByName('MAT_ID').AsInteger,
        Q.FieldByName('MAT_NAZIV').AsString,
        Q.FieldByName('MAT_TIP').AsString,
        Q.FieldByName('MAT_ZALIHA').AsFloat,
        Q.FieldByName('MAT_MIN_ZAL').AsFloat,
        Y
      );
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{ ===================================================================
  NALOG DETAIL — sa rezervnim delovima i fotografijama
  =================================================================== }

procedure TfrmMain.LoadDelMatCombo;
var Q: TFDQuery;
begin
  cmbDelMat.Items.Clear;
  SetLength(FDelMatIDs, 0);
  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT MAT_ID, MAT_NAZIV, MAT_JEDINICA, MAT_ZALIHA FROM MATERIJAL ORDER BY MAT_NAZIV';
    Q.Open;
    while not Q.Eof do
    begin
      cmbDelMat.Items.Add(
        Q.FieldByName('MAT_NAZIV').AsString + ' [' +
        Q.FieldByName('MAT_JEDINICA').AsString + '] — zal: ' +
        Format('%.1f', [Q.FieldByName('MAT_ZALIHA').AsFloat])
      );
      SetLength(FDelMatIDs, Length(FDelMatIDs) + 1);
      FDelMatIDs[High(FDelMatIDs)] := Q.FieldByName('MAT_ID').AsInteger;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.RefreshNalogDelovi(AID: Integer; var AY: Single);
var Q: TFDQuery; PR: TRectangle; lKol: TLabel;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT M.MAT_NAZIV, P.P_KOLICINA, M.MAT_JEDINICA, P.P_DATUM ' +
      'FROM POTROSNJA P JOIN MATERIJAL M ON M.MAT_ID=P.P_MAT_ID ' +
      'WHERE P.P_RN_ID=:ID ORDER BY P.P_DATUM DESC';
    Q.ParamByName('ID').AsInteger := AID;
    Q.Open;

    if not Q.IsEmpty then
    begin
      MkLbl(sbNalogDetail.Content, 'Utroseni rezervni delovi', 16, AY, 340, 20, 11, True).FontColor := CLR_DIM;
      AY := AY + 26;
      while not Q.Eof do
      begin
        PR := MkRect(sbNalogDetail.Content, 16, AY, 388, 38, CLR_CARD, 8);
        MkLbl(PR, Q.FieldByName('MAT_NAZIV').AsString, 12, 9, 230, 20, 12);
        lKol := MkLbl(PR, Format('%.2f %s', [Q.FieldByName('P_KOLICINA').AsFloat,
          Q.FieldByName('MAT_JEDINICA').AsString]), 250, 9, 126, 20, 12);
        lKol.TextSettings.HorzAlign := TTextAlign.Trailing;
        lKol.FontColor := CLR_BRIGHT;
        AY := AY + 46;
        Q.Next;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.LoadFotoFromDB(AID: Integer; AField: string; AImg: TImage);
var Q: TFDQuery; MS: TMemoryStream;
begin
  AImg.Bitmap.SetSize(0, 0);
  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  MS := TMemoryStream.Create;
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT ' + AField + ' FROM RADNI_NALOG WHERE RN_ID=:ID';
    Q.ParamByName('ID').AsInteger := AID;
    Q.Open;
    if not Q.IsEmpty and not Q.Fields[0].IsNull then
    begin
      (Q.Fields[0] as TBlobField).SaveToStream(MS);
      MS.Position := 0;
      AImg.Bitmap.LoadFromStream(MS);
    end;
  finally
    Q.Free;
    MS.Free;
  end;
end;

procedure TfrmMain.SaveFotoDB(AID: Integer; AField: string; const AData: TBytes);
var Q: TFDQuery; MS: TMemoryStream;
begin
  if not dmData.IsConnected then Exit;
  if Length(AData) = 0 then Exit;
  MS := TMemoryStream.Create;
  Q := TFDQuery.Create(nil);
  try
    MS.WriteBuffer(AData[0], Length(AData));
    MS.Position := 0;
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'UPDATE RADNI_NALOG SET ' + AField + '=:FOTO WHERE RN_ID=:ID';
    Q.ParamByName('FOTO').LoadFromStream(MS, ftBlob);
    Q.ParamByName('ID').AsInteger := AID;
    Q.ExecSQL;
    dmData.CommitWork;
  finally
    Q.Free;
    MS.Free;
  end;
end;

procedure TfrmMain.btnDodajFotoOtvarClick(Sender: TObject);
var OD: TOpenDialog; MS: TMemoryStream;
begin
  OD := TOpenDialog.Create(nil);
  try
    OD.Filter := 'Slike|*.jpg;*.jpeg;*.png;*.bmp';
    OD.Title := 'Izaberi fotografiju — otvaranje naloga';
    if OD.Execute then
    begin
      MS := TMemoryStream.Create;
      try
        MS.LoadFromFile(OD.FileName);
        SetLength(FFotoOtvarData, MS.Size);
        MS.Position := 0;
        MS.ReadBuffer(FFotoOtvarData[0], MS.Size);
      finally
        MS.Free;
      end;
      imgFotoOtvar.Bitmap.LoadFromFile(OD.FileName);
      SaveFotoDB(FNalogCurrentID, 'RN_FOTO_OTVAR_BLOB', FFotoOtvarData);
      ShowMessage('Fotografija sacuvana u bazu.');
    end;
  finally
    OD.Free;
  end;
end;

procedure TfrmMain.btnDodajFotoZatvrClick(Sender: TObject);
var OD: TOpenDialog; MS: TMemoryStream;
begin
  OD := TOpenDialog.Create(nil);
  try
    OD.Filter := 'Slike|*.jpg;*.jpeg;*.png;*.bmp';
    OD.Title := 'Izaberi fotografiju — zatvaranje naloga';
    if OD.Execute then
    begin
      MS := TMemoryStream.Create;
      try
        MS.LoadFromFile(OD.FileName);
        SetLength(FFotoZatvrData, MS.Size);
        MS.Position := 0;
        MS.ReadBuffer(FFotoZatvrData[0], MS.Size);
      finally
        MS.Free;
      end;
      imgFotoZatvr.Bitmap.LoadFromFile(OD.FileName);
      SaveFotoDB(FNalogCurrentID, 'RN_FOTO_ZATVR_BLOB', FFotoZatvrData);
      ShowMessage('Fotografija sacuvana u bazu.');
    end;
  finally
    OD.Free;
  end;
end;

procedure TfrmMain.btnDodajDelNaloguClick(Sender: TObject);
begin
  LoadDelMatCombo;
  pnlDelForm.Visible := True;
  edtDelKol.Text := '1';
  lblDelErr.Text := '';
end;

procedure TfrmMain.btnSnimiDelNaloguClick(Sender: TObject);
var Q: TFDQuery; Kol: Double; MatID: Integer;
begin
  lblDelErr.Text := '';
  if cmbDelMat.ItemIndex < 0 then
  begin lblDelErr.Text := 'Izaberite materijal.'; Exit; end;
  if not TryStrToFloat(edtDelKol.Text, Kol) or (Kol <= 0) then
  begin lblDelErr.Text := 'Unesite ispravnu kolicinu.'; Exit; end;

  MatID := FDelMatIDs[cmbDelMat.ItemIndex];

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    { Upiši potrošnju }
    Q.SQL.Text :=
      'INSERT INTO POTROSNJA (P_RN_ID, P_MAT_ID, P_KOLICINA, P_DATUM) ' +
      'VALUES (:RN, :MAT, :KOL, CURRENT_TIMESTAMP)';
    Q.ParamByName('RN').AsInteger  := FNalogCurrentID;
    Q.ParamByName('MAT').AsInteger := MatID;
    Q.ParamByName('KOL').AsFloat   := Kol;
    Q.ExecSQL;

    { Smanji zalihu }
    Q.SQL.Text :=
      'UPDATE MATERIJAL SET MAT_ZALIHA = MAT_ZALIHA - :KOL WHERE MAT_ID = :ID';
    Q.ParamByName('KOL').AsFloat   := Kol;
    Q.ParamByName('ID').AsInteger  := MatID;
    Q.ExecSQL;

    dmData.CommitWork;
  except
    on E: Exception do begin lblDelErr.Text := 'Greska: ' + E.Message; Exit; end;
  end;
  Q.Free;

  pnlDelForm.Visible := False;
  { Osvezi prikaz detalja }
  ShowNalogDetail(FNalogCurrentID);
end;

procedure TfrmMain.btnOtkaziDelNaloguClick(Sender: TObject);
begin
  pnlDelForm.Visible := False;
end;

procedure TfrmMain.ShowNalogDetail(AID: Integer);
const FW = 420; CW = FW - 32;
var
  Q: TFDQuery;
  Y: Single;
  I: Integer;
  StatC: TAlphaColor;
  RowCard: TRectangle;
  RowKey, RowVal: TLabel;
  OpR: TRectangle;
  lOpis: TLabel;
  btnAddDel: TCornerButton;
  FrOtv, FrZtv: TRectangle;
  btnFOtv, btnFZtv: TCornerButton;
begin
  FNalogCurrentID := AID;

  for I := sbNalogDetail.Content.ChildrenCount - 1 downto 0 do
    sbNalogDetail.Content.Children[I].Parent := nil;

  FFotoOtvarData := nil;
  FFotoZatvrData := nil;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT R.RN_ID, R.RN_TIP, R.RN_KATEGORIJA, R.RN_PRIORITET, R.RN_STATUS, ' +
      '       R.RN_IZVRSIO, R.RN_DATUM_OTVAR, R.RN_DATUM_ZATVR, ' +
      '       R.RN_TROSAK, R.RN_BLOKIRA_REZ, R.RN_OPIS, ' +
      '       B.B_NAZIV, O.OP_NAZIV ' +
      'FROM RADNI_NALOG R ' +
      'LEFT JOIN BAZEN B ON B.B_ID=R.RN_BAZEN_ID ' +
      'LEFT JOIN OPREMA O ON O.OP_ID=R.RN_OPREMA_ID ' +
      'WHERE R.RN_ID=:ID';
    Q.ParamByName('ID').AsInteger := AID;
    Q.Open;

    if Q.IsEmpty then Exit;

    lblNalogDetTitle.Text := Q.FieldByName('RN_TIP').AsString + ' — #' + IntToStr(AID);

    Y := 8;

    if Q.FieldByName('RN_STATUS').AsString = 'Zatvoren' then StatC := CLR_GREEN
    else if Q.FieldByName('RN_STATUS').AsString = 'U radu' then StatC := CLR_BLUE
    else StatC := CLR_ORANGE;

    { ---- Informativni redovi — inlajn umesto lokalne procedure ---- }
    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Status', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_STATUS').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := StatC;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Tip', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_TIP').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Kategorija', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_KATEGORIJA').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Prioritet', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_PRIORITET').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Bazen', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('B_NAZIV').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Oprema', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('OP_NAZIV').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Izvrsio', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_IZVRSIO').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Otvoren', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_DATUM_OTVAR').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    if not Q.FieldByName('RN_DATUM_ZATVR').IsNull then
    begin
      RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
      RowKey := MkLbl(RowCard, 'Zatvoren', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
      RowVal := MkLbl(RowCard, Q.FieldByName('RN_DATUM_ZATVR').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_GREEN;
      Y := Y + 52;
    end;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Trosak', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Format('%.2f RSD', [Q.FieldByName('RN_TROSAK').AsFloat]), 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    RowCard := MkRect(sbNalogDetail.Content, 16, Y, 388, 44, CLR_CARD, 10);
    RowKey := MkLbl(RowCard, 'Blokira rez.', 14, 4, 130, 18, 10); RowKey.FontColor := CLR_DIM;
    RowVal := MkLbl(RowCard, Q.FieldByName('RN_BLOKIRA_REZ').AsString, 14, 22, 360, 18, 12, True); RowVal.FontColor := CLR_WHITE;
    Y := Y + 52;

    { Opis }
    MkLbl(sbNalogDetail.Content, 'Opis radova', 16, Y, 300, 20, 11).FontColor := CLR_DIM;
    Y := Y + 22;
    OpR := MkRect(sbNalogDetail.Content, 16, Y, 388, 80, CLR_CARD, 10);
    lOpis := MkLbl(OpR, Q.FieldByName('RN_OPIS').AsString, 12, 8, 364, 64, 12);
    lOpis.WordWrap := True;
    Y := Y + 88;

    { ============================================================
      REZERVNI DELOVI — lista + dugme za dodavanje
      ============================================================ }
    RefreshNalogDelovi(AID, Y);

    { Dugme "+ Dodaj rezervni deo" }
    btnAddDel := MkBtn(sbNalogDetail.Content, '+ Dodaj rezervni deo', 16, Y, CW, 40, CLR_CARD2);
    btnAddDel.OnClick := btnDodajDelNaloguClick;
    Y := Y + 48;

    { Mini-forma za unos dela (skrivena) }
    pnlDelForm := MkRect(sbNalogDetail.Content, 16, Y, 388, 148, $FF0D2A4A, 12);
    pnlDelForm.Visible := False;

    MkLbl(pnlDelForm, 'Materijal / deo *', 10, 8, 340, 18, 10).FontColor := CLR_DIM;
    cmbDelMat := MkCombo(pnlDelForm, 10, 26, 368);
    MkLbl(pnlDelForm, 'Kolicina', 10, 74, 100, 18, 10).FontColor := CLR_DIM;
    edtDelKol := MkEdit(pnlDelForm, '1', 10, 92, 120);
    lblDelErr := MkLbl(pnlDelForm, '', 10, 118, 368, 18, 10);
    lblDelErr.FontColor := CLR_RED;
    MkBtn(pnlDelForm, 'Sacuvaj', 200, 92, 178, 36, CLR_GREEN).OnClick := btnSnimiDelNaloguClick;
    MkBtn(pnlDelForm, 'Otkazi', 10, 118, 120, 28, CLR_CARD2).OnClick := btnOtkaziDelNaloguClick;
    Y := Y + 156;

    { ============================================================
      FOTOGRAFIJE
      ============================================================ }
    MkLbl(sbNalogDetail.Content, 'Fotografije', 16, Y, 300, 20, 11, True).FontColor := CLR_DIM;
    Y := Y + 26;

    { Foto otvaranja }
    MkLbl(sbNalogDetail.Content, 'Otvaranje naloga', 16, Y, 200, 18, 10).FontColor := CLR_DIM;
    Y := Y + 20;
    imgFotoOtvar := TImage.Create(Self);
    imgFotoOtvar.Parent := sbNalogDetail.Content;
    imgFotoOtvar.Position.X := 16; imgFotoOtvar.Position.Y := Y;
    imgFotoOtvar.Width := 180; imgFotoOtvar.Height := 135;
    imgFotoOtvar.WrapMode := TImageWrapMode.Fit;
    { Okvir }
    FrOtv := MkRect(sbNalogDetail.Content, 16, Y, 180, 135, $FF0D2444, 8);
    FrOtv.Stroke.Color := CLR_CARD2;
    FrOtv.Stroke.Kind := TBrushKind.Solid;
    imgFotoOtvar.BringToFront;

    btnFOtv := MkBtn(sbNalogDetail.Content, 'Dodaj/zameni', 204, Y + 48, 180, 40, CLR_CARD2);
    btnFOtv.OnClick := btnDodajFotoOtvarClick;

    LoadFotoFromDB(AID, 'RN_FOTO_OTVAR_BLOB', imgFotoOtvar);
    Y := Y + 145;

    { Foto zatvaranja }
    MkLbl(sbNalogDetail.Content, 'Zatvaranje naloga', 16, Y, 200, 18, 10).FontColor := CLR_DIM;
    Y := Y + 20;
    imgFotoZatvr := TImage.Create(Self);
    imgFotoZatvr.Parent := sbNalogDetail.Content;
    imgFotoZatvr.Position.X := 16; imgFotoZatvr.Position.Y := Y;
    imgFotoZatvr.Width := 180; imgFotoZatvr.Height := 135;
    imgFotoZatvr.WrapMode := TImageWrapMode.Fit;
    FrZtv := MkRect(sbNalogDetail.Content, 16, Y, 180, 135, $FF0D2444, 8);
    FrZtv.Stroke.Color := CLR_CARD2;
    FrZtv.Stroke.Kind := TBrushKind.Solid;
    imgFotoZatvr.BringToFront;

    btnFZtv := MkBtn(sbNalogDetail.Content, 'Dodaj/zameni', 204, Y + 48, 180, 40, CLR_CARD2);
    btnFZtv.OnClick := btnDodajFotoZatvrClick;

    LoadFotoFromDB(AID, 'RN_FOTO_ZATVR_BLOB', imgFotoZatvr);
    Y := Y + 155;

  finally
    Q.Free;
  end;

  tcMain.ActiveTab := tiNalogDetail;
end;

{ ===================================================================
  AUTH
  =================================================================== }

function TfrmMain.SimpleHash(const S: string): string;
var
  I, H: Integer;
begin
  { Simple deterministic hash — adequate for embedded single-user app }
  H := 5381;
  for I := 1 to Length(S) do
    H := ((H shl 5) + H) + Ord(S[I]);
  Result := IntToHex(H, 8);
end;

procedure TfrmMain.btnGoRegisterClick(Sender: TObject);
begin
  edtRegEmpID.Text := '';
  edtRegUsername.Text := '';
  edtRegPass.Text := '';
  edtRegPass2.Text := '';
  lblRegErr.Text := '';
  tcMain.ActiveTab := tiRegister;
end;

procedure TfrmMain.btnBackToLoginClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.btnRegisterClick(Sender: TObject);
var
  Q: TFDQuery;
begin
  lblRegErr.Text := '';
  if Trim(edtRegEmpID.Text) = '' then
  begin lblRegErr.Text := 'ID zaposlenog je obavezan.'; Exit; end;
  if Trim(edtRegUsername.Text) = '' then
  begin lblRegErr.Text := 'Korisnicko ime je obavezno.'; Exit; end;
  if Length(Trim(edtRegPass.Text)) < 4 then
  begin lblRegErr.Text := 'Lozinka mora imati najmanje 4 karaktera.'; Exit; end;
  if edtRegPass.Text <> edtRegPass2.Text then
  begin lblRegErr.Text := 'Lozinke se ne podudaraju.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    { Check username not taken }
    Q.SQL.Text := 'SELECT COUNT(*) FROM KORISNIK_ODR WHERE KO_USERNAME = :UN';
    Q.ParamByName('UN').AsString := Trim(edtRegUsername.Text);
    Q.Open;
    if Q.Fields[0].AsInteger > 0 then
    begin
      lblRegErr.Text := 'Korisnicko ime vec postoji.';
      Exit;
    end;
    Q.Close;

    Q.SQL.Text :=
      'INSERT INTO KORISNIK_ODR (KO_EMP_ID, KO_USERNAME, KO_PASSHASH) ' +
      'VALUES (:EMP, :UN, :HASH)';
    Q.ParamByName('EMP').AsString  := Trim(edtRegEmpID.Text);
    Q.ParamByName('UN').AsString   := Trim(edtRegUsername.Text);
    Q.ParamByName('HASH').AsString := SimpleHash(Trim(edtRegPass.Text));
    Q.ExecSQL;
    dmData.CommitWork;

    ShowMessage('Registracija uspjesna! Mozete se prijaviti.');
    tcMain.ActiveTab := tiLogin;
  except
    on E: Exception do
      lblRegErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

{ ===================================================================
  FORM EVENTS
  =================================================================== }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FLoggedKoID := 0;
  FLoggedUsername := '';
  FPrevProfilTab := nil;
  SetLength(FFotoNewData, 0);
  BuildUI;
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  tcMain.ActiveTab := tiLogin;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  // Unit2 handles cleanup
end;

{ ===================================================================
  NAVIGATION
  =================================================================== }

procedure TfrmMain.btnLoginClick(Sender: TObject);
var
  Q: TFDQuery;
  StoredHash: string;
begin
  lblLoginErr.Text := '';
  if Trim(edtUser.Text) = '' then
  begin lblLoginErr.Text := 'Unesite korisnicko ime.'; Exit; end;
  if Trim(edtPass.Text) = '' then
  begin lblLoginErr.Text := 'Unesite lozinku.'; Exit; end;
  if not dmData.IsConnected then
  begin lblLoginErr.Text := 'Baza nije dostupna.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT KO_ID, KO_PASSHASH FROM KORISNIK_ODR ' +
      'WHERE KO_USERNAME = :UN';
    Q.ParamByName('UN').AsString := Trim(edtUser.Text);
    Q.Open;
    if Q.IsEmpty then
    begin
      lblLoginErr.Text := 'Korisnik nije pronadjen.';
      Exit;
    end;
    StoredHash := Q.FieldByName('KO_PASSHASH').AsString;
    if StoredHash <> SimpleHash(Trim(edtPass.Text)) then
    begin
      lblLoginErr.Text := 'Pogresna lozinka.';
      Exit;
    end;
    FLoggedKoID := Q.FieldByName('KO_ID').AsInteger;
    FLoggedUsername := Trim(edtUser.Text);
  finally
    Q.Free;
  end;

  edtUser.Text := '';
  edtPass.Text := '';
  tcMain.ActiveTab := tiDashboard;
  RefreshDashboard;
  LoadMerenja;
  LoadNalozi;
  LoadOprema;
  LoadMagacin;
end;

procedure TfrmMain.btnNavDashClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiDashboard;
  RefreshDashboard;
end;

procedure TfrmMain.btnNavMerenjeClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMerenje;
  LoadMerenja;
end;

procedure TfrmMain.btnNavNaloziClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiNalozi;
  LoadNalozi(cmbNalogFilter.Text);
end;

procedure TfrmMain.btnNavOpremaClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiOprema;
  LoadOprema;
end;

procedure TfrmMain.btnNavMagacinClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMagacin;
  LoadMagacin;
end;

procedure TfrmMain.btnRefreshDashClick(Sender: TObject);
begin
  RefreshDashboard;
end;

{ ===================================================================
  MERENJA
  =================================================================== }

procedure TfrmMain.btnNovoMerenjeClick(Sender: TObject);
begin
  LoadBazenCombo(cmbMerBazen);
  edtMerPH.Text := ''; edtMerHlor.Text := '';
  edtMerTemp.Text := ''; edtMerUneo.Text := '';
  lblMerErr.Text := '';
  tcMain.ActiveTab := tiMerenjeForm;
end;

procedure TfrmMain.btnSaveMerenjeClick(Sender: TObject);
var
  Q: TFDQuery;
  PH, Hlor, Temp: Double;
  Alarm: string;
  BazenID: Integer;
begin
  lblMerErr.Text := '';
  if cmbMerBazen.ItemIndex <= 0 then
  begin lblMerErr.Text := 'Izaberite bazen.'; Exit; end;
  if not TryStrToFloat(edtMerPH.Text, PH) then
  begin lblMerErr.Text := 'Unesite ispravnu pH vrednost.'; Exit; end;
  if not TryStrToFloat(edtMerHlor.Text, Hlor) then
  begin lblMerErr.Text := 'Unesite ispravnu vrednost hlora.'; Exit; end;
  if not TryStrToFloat(edtMerTemp.Text, Temp) then
  begin lblMerErr.Text := 'Unesite ispravnu temperaturu.'; Exit; end;

  { Provera granica: pH 6.8-7.6, Hlor 0.5-2.0 }
  if (PH < 6.8) or (PH > 7.6) or (Hlor < 0.5) or (Hlor > 2.0) then
    Alarm := 'Y'
  else
    Alarm := 'N';

  BazenID := FBazenIDs[cmbMerBazen.ItemIndex];

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'INSERT INTO MERENJE_VODE (MV_BAZEN_ID, MV_DATUM, MV_PH, MV_HLOR, MV_TEMP, MV_UNEO, MV_ALARM, MV_NAPOMENA) ' +
      'VALUES (:BID, :DATUM, :PH, :HLOR, :TEMP, :UNEO, :ALARM, :NAP)';
    Q.ParamByName('BID').AsInteger := BazenID;
    Q.ParamByName('DATUM').AsDateTime := Now;
    Q.ParamByName('PH').AsFloat := PH;
    Q.ParamByName('HLOR').AsFloat := Hlor;
    Q.ParamByName('TEMP').AsFloat := Temp;
    Q.ParamByName('UNEO').AsString := Trim(edtMerUneo.Text);
    Q.ParamByName('ALARM').AsString := Alarm;
    if Alarm = 'Y' then
      Q.ParamByName('NAP').AsString :=
        Format('ALARM: pH=%.2f (6.8-7.6), Hlor=%.3f (0.5-2.0)', [PH, Hlor])
    else
      Q.ParamByName('NAP').AsString := '';
    Q.ExecSQL;
    dmData.CommitWork;

    { Ako su vrednosti OK, ocisti alarme za ovaj bazen }
    if Alarm = 'N' then
    begin
      Q.SQL.Text :=
        'UPDATE MERENJE_VODE SET MV_ALARM=''N'' ' +
        'WHERE MV_BAZEN_ID=:BID AND MV_ALARM=''Y''';
      Q.ParamByName('BID').AsInteger := BazenID;
      Q.ExecSQL;
      dmData.CommitWork;
    end;

    { Ako je alarm, automatski otvori nalog }
    if Alarm = 'Y' then
    begin
      Q.SQL.Text :=
        'INSERT INTO RADNI_NALOG (RN_BAZEN_ID, RN_DATUM_OTVAR, RN_TIP, RN_KATEGORIJA, ' +
        'RN_OPIS, RN_STATUS, RN_PRIORITET, RN_BLOKIRA_REZ) ' +
        'VALUES (:BID, :DATUM, ''Hitno'', ''Kvalitet vode'', :OPIS, ''Otvoren'', 1, ''Y'')';
      Q.ParamByName('BID').AsInteger := BazenID;
      Q.ParamByName('DATUM').AsDateTime := Now;
      Q.ParamByName('OPIS').AsString :=
        Format('AUTOMATSKI NALOG: Merenje van granica — pH=%.2f, Hlor=%.3f. Rezervacije blokirane.', [PH, Hlor]);
      Q.ExecSQL;
      dmData.CommitWork;
      ShowMessage('! ALARM! Parametri van granica.' + #13#10 +
        'Automatski otvoren hitni nalog.' + #13#10 +
        'Rezervacije za ovaj bazen su blokirane.');
    end;

    LoadMerenja;
    tcMain.ActiveTab := tiMerenje;
  except
    on E: Exception do lblMerErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelMerenjeClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMerenje;
end;

{ ===================================================================
  RADNI NALOZI
  =================================================================== }

procedure TfrmMain.btnNoviNalogClick(Sender: TObject);
begin
  LoadBazenCombo(cmbNalogBazen);
  LoadOpremaCombo;
  cmbNalogTip.Text := 'Preventivno';
  cmbNalogPrior.Text := '3 - Normalan';
  cmbNalogBazen.ItemIndex := 0;
  cmbNalogOprema.ItemIndex := 0;
  edtNalogIzvrsio.Text := '';
  memoNalogOpis.Text := '';
  chkBlokiraj.IsChecked := False;
  lblNalogErr.Text := '';
  SetLength(FFotoNewData, 0);
  if Assigned(imgFotoNalogNew) then imgFotoNalogNew.Bitmap.Clear(0);
  SetLength(FNewNalogDelovi, 0);
  if Assigned(sbDelNewList) then
    while sbDelNewList.Content.ChildrenCount > 0 do
      sbDelNewList.Content.Children[0].Parent := nil;
  if Assigned(pnlDelNewForm) then pnlDelNewForm.Visible := False;
  if Assigned(lblDelNewErr) then lblDelNewErr.Text := '';
  tcMain.ActiveTab := tiNalogForm;
end;

procedure TfrmMain.cmbNalogFilterChange(Sender: TObject);
begin
  LoadNalozi(cmbNalogFilter.Text);
end;

procedure TfrmMain.NalogCardClick(Sender: TObject);
begin
  ShowNalogDetail(TControl(Sender).Tag);
end;

procedure TfrmMain.MerenjeCardClick(Sender: TObject);
var
  Q: TFDQuery;
  ID: Integer;
  Msg: string;
begin
  ID := TControl(Sender).Tag;
  if not dmData.IsConnected then Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'SELECT M.MV_DATUM, B.B_NAZIV, M.MV_PH, M.MV_HLOR, M.MV_TEMP, ' +
      'M.MV_UNEO, M.MV_ALARM, M.MV_NAPOMENA ' +
      'FROM MERENJE_VODE M JOIN BAZEN B ON B.B_ID=M.MV_BAZEN_ID ' +
      'WHERE M.MV_ID=:ID';
    Q.ParamByName('ID').AsInteger := ID;
    Q.Open;
    if not Q.IsEmpty then
    begin
      Msg := 'Bazen:    ' + Q.FieldByName('B_NAZIV').AsString + #13#10 +
             'Datum:    ' + FormatDateTime('dd.mm.yyyy  hh:nn', Q.FieldByName('MV_DATUM').AsDateTime) + #13#10 +
             '' + #13#10 +
             'pH:       ' + Format('%.2f  (granica 6.8-7.6)', [Q.FieldByName('MV_PH').AsFloat]) + #13#10 +
             'Hlor:     ' + Format('%.3f mg/L  (0.5-2.0)', [Q.FieldByName('MV_HLOR').AsFloat]) + #13#10 +
             'Temp.:    ' + Format('%.1f°C', [Q.FieldByName('MV_TEMP').AsFloat]) + #13#10 +
             '' + #13#10 +
             'Uneo:     ' + Q.FieldByName('MV_UNEO').AsString + #13#10 +
             'Status:   ';
      if Q.FieldByName('MV_ALARM').AsString = 'Y' then
        Msg := Msg + '! ALARM - vrednosti van granica'
      else
        Msg := Msg + 'OK - vrednosti u granicama';
      if Q.FieldByName('MV_NAPOMENA').AsString <> '' then
        Msg := Msg + #13#10 + 'Napomena: ' + Q.FieldByName('MV_NAPOMENA').AsString;
      ShowMessage(Msg);
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.btnSaveNalogClick(Sender: TObject);
var
  Q: TFDQuery;
  Prior: Integer;
  Blok: string;
  NewID: Integer;
  I: Integer;
begin
  lblNalogErr.Text := '';
  if Trim(memoNalogOpis.Text) = '' then
  begin lblNalogErr.Text := 'Opis je obavezan.'; Exit; end;
  if cmbNalogTip.Text = '' then
  begin lblNalogErr.Text := 'Tip je obavezan.'; Exit; end;

  Prior := 3;
  if Pos('1', cmbNalogPrior.Text) > 0 then Prior := 1
  else if Pos('2', cmbNalogPrior.Text) > 0 then Prior := 2;

  Blok := 'N';
  if chkBlokiraj.IsChecked then Blok := 'Y';

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'INSERT INTO RADNI_NALOG ' +
      '(RN_BAZEN_ID, RN_OPREMA_ID, RN_DATUM_OTVAR, RN_TIP, RN_KATEGORIJA, ' +
      ' RN_OPIS, RN_IZVRSIO, RN_STATUS, RN_PRIORITET, RN_BLOKIRA_REZ) ' +
      'VALUES (:BID, :OID, :DATUM, :TIP, :KAT, :OPIS, :IZV, ''Otvoren'', :PRIOR, :BLOK)';

    if (cmbNalogBazen.ItemIndex > 0) and (cmbNalogBazen.ItemIndex <= High(FBazenIDs)) then
      Q.ParamByName('BID').AsInteger := FBazenIDs[cmbNalogBazen.ItemIndex]
    else
      Q.ParamByName('BID').Clear;

    if (cmbNalogOprema.ItemIndex > 0) and (cmbNalogOprema.ItemIndex <= High(FOpremaIDs)) then
      Q.ParamByName('OID').AsInteger := FOpremaIDs[cmbNalogOprema.ItemIndex]
    else
      Q.ParamByName('OID').Clear;

    Q.ParamByName('DATUM').AsDateTime := Now;
    Q.ParamByName('TIP').AsString   := cmbNalogTip.Text;
    Q.ParamByName('KAT').AsString   := cmbNalogKat.Text;
    Q.ParamByName('OPIS').AsString  := Trim(memoNalogOpis.Text);
    Q.ParamByName('IZV').AsString   := Trim(edtNalogIzvrsio.Text);
    Q.ParamByName('PRIOR').AsInteger := Prior;
    Q.ParamByName('BLOK').AsString  := Blok;
    Q.ExecSQL;
    dmData.CommitWork;

    { Uzmi ID novokreiranog naloga }
    Q.SQL.Text := 'SELECT MAX(RN_ID) FROM RADNI_NALOG';
    Q.Open;
    NewID := Q.Fields[0].AsInteger;
    Q.Close;

    { Upiši rezervne delove ako ih ima }
    if Length(FNewNalogDelovi) > 0 then
    begin
      for I := 0 to High(FNewNalogDelovi) do
      begin
        Q.SQL.Text :=
          'INSERT INTO POTROSNJA (P_RN_ID, P_MAT_ID, P_KOLICINA, P_DATUM) ' +
          'VALUES (:RN, :MAT, :KOL, CURRENT_TIMESTAMP)';
        Q.ParamByName('RN').AsInteger  := NewID;
        Q.ParamByName('MAT').AsInteger := FNewNalogDelovi[I].MatID;
        Q.ParamByName('KOL').AsFloat   := FNewNalogDelovi[I].Kol;
        Q.ExecSQL;
        Q.SQL.Text :=
          'UPDATE MATERIJAL SET MAT_ZALIHA = MAT_ZALIHA - :KOL WHERE MAT_ID = :ID';
        Q.ParamByName('KOL').AsFloat   := FNewNalogDelovi[I].Kol;
        Q.ParamByName('ID').AsInteger  := FNewNalogDelovi[I].MatID;
        Q.ExecSQL;
      end;
      dmData.CommitWork;
      SetLength(FNewNalogDelovi, 0);
    end;

    LoadNalozi(cmbNalogFilter.Text);
    tcMain.ActiveTab := tiNalozi;
  except
    on E: Exception do lblNalogErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelNalogClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiNalozi;
end;

procedure TfrmMain.btnZatvoriNalogClick(Sender: TObject);
var Q: TFDQuery;
begin
  if FMX.Dialogs.MessageDlg('Zatvoriti ovaj nalog? Rezervacije ce biti ponovo omogucene.',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) <> mrYes then Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'UPDATE RADNI_NALOG SET RN_STATUS=''Zatvoren'', ' +
      'RN_DATUM_ZATVR=:DATUM, RN_BLOKIRA_REZ=''N'' WHERE RN_ID=:ID';
    Q.ParamByName('DATUM').AsDateTime := Now;
    Q.ParamByName('ID').AsInteger := FNalogCurrentID;
    Q.ExecSQL;
    dmData.CommitWork;
    LoadNalozi(cmbNalogFilter.Text);
    ShowNalogDetail(FNalogCurrentID);
    RefreshDashboard;
  finally
    Q.Free;
  end;
end;

procedure TfrmMain.btnBackNalogClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiNalozi;
end;

{ ===================================================================
  OPREMA
  =================================================================== }

procedure TfrmMain.btnNovaOpremaClick(Sender: TObject);
begin
  LoadBazenCombo(cmbOpBazen);
  FOpIsNew := True; FOpCurrentID := -1;
  edtOpNaziv.Text := ''; cmbOpTip.Text := 'Pumpa';
  cmbOpStatus.Text := 'Aktivna'; edtOpModel.Text := '';
  edtOpSerial.Text := ''; edtOpDatum.Text := '';
  memoOpNap.Text := ''; cmbOpBazen.ItemIndex := 0;
  lblOpErr.Text := '';
  tcMain.ActiveTab := tiOpremaForm;
end;

procedure TfrmMain.OpremaCardClick(Sender: TObject);
var Q: TFDQuery; BID, I: Integer;
begin
  FOpIsNew := False;
  FOpCurrentID := TControl(Sender).Tag;
  LoadBazenCombo(cmbOpBazen);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text := 'SELECT * FROM OPREMA WHERE OP_ID=:ID';
    Q.ParamByName('ID').AsInteger := FOpCurrentID;
    Q.Open;
    if not Q.IsEmpty then
    begin
      edtOpNaziv.Text  := Q.FieldByName('OP_NAZIV').AsString;
      cmbOpTip.Text    := Q.FieldByName('OP_TIP').AsString;
      cmbOpStatus.Text := Q.FieldByName('OP_STATUS').AsString;
      edtOpModel.Text  := Q.FieldByName('OP_MODEL').AsString;
      edtOpSerial.Text := Q.FieldByName('OP_SERIJSKI').AsString;
      edtOpDatum.Text  := Q.FieldByName('OP_DATUM_NABAVKE').AsString;
      memoOpNap.Text   := Q.FieldByName('OP_NAPOMENA').AsString;
      BID := Q.FieldByName('OP_BAZEN_ID').AsInteger;
      cmbOpBazen.ItemIndex := 0;
      for I := 0 to High(FBazenIDs) do
        if FBazenIDs[I] = BID then begin cmbOpBazen.ItemIndex := I; Break; end;
    end;
  finally
    Q.Free;
  end;
  lblOpErr.Text := '';
  tcMain.ActiveTab := tiOpremaForm;
end;

procedure TfrmMain.btnSaveOpremaClick(Sender: TObject);
var Q: TFDQuery;
begin
  lblOpErr.Text := '';
  if Trim(edtOpNaziv.Text) = '' then begin lblOpErr.Text := 'Naziv je obavezan.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    if FOpIsNew then
      Q.SQL.Text :=
        'INSERT INTO OPREMA (OP_NAZIV,OP_TIP,OP_STATUS,OP_BAZEN_ID,OP_MODEL,OP_SERIJSKI,OP_DATUM_NABAVKE,OP_NAPOMENA) ' +
        'VALUES (:NAZ,:TIP,:STAT,:BID,:MOD,:SER,:DAT,:NAP)'
    else
    begin
      Q.SQL.Text :=
        'UPDATE OPREMA SET OP_NAZIV=:NAZ,OP_TIP=:TIP,OP_STATUS=:STAT,OP_BAZEN_ID=:BID,' +
        'OP_MODEL=:MOD,OP_SERIJSKI=:SER,OP_DATUM_NABAVKE=:DAT,OP_NAPOMENA=:NAP WHERE OP_ID=:ID';
      Q.ParamByName('ID').AsInteger := FOpCurrentID;
    end;
    Q.ParamByName('NAZ').AsString  := Trim(edtOpNaziv.Text);
    Q.ParamByName('TIP').AsString  := cmbOpTip.Text;
    Q.ParamByName('STAT').AsString := cmbOpStatus.Text;
    Q.ParamByName('MOD').AsString  := Trim(edtOpModel.Text);
    Q.ParamByName('SER').AsString  := Trim(edtOpSerial.Text);
    Q.ParamByName('NAP').AsString  := Trim(memoOpNap.Text);
    if (cmbOpBazen.ItemIndex > 0) and (cmbOpBazen.ItemIndex <= High(FBazenIDs)) then
      Q.ParamByName('BID').AsInteger := FBazenIDs[cmbOpBazen.ItemIndex]
    else
      Q.ParamByName('BID').Clear;
    if Trim(edtOpDatum.Text) <> '' then
      Q.ParamByName('DAT').AsDate := StrToDateDef(edtOpDatum.Text, Date)
    else
      Q.ParamByName('DAT').Clear;
    Q.ExecSQL;
    dmData.CommitWork;
    LoadOprema;
    tcMain.ActiveTab := tiOprema;
  except
    on E: Exception do lblOpErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelOpremaClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiOprema;
end;

{ ===================================================================
  MAGACIN
  =================================================================== }

procedure TfrmMain.btnNoviMatClick(Sender: TObject);
begin
  FMatIsNew := True; FMatCurrentID := -1;
  edtMatNaziv.Text := ''; cmbMatTip.Text := 'Hemija';
  edtMatJed.Text := 'kg'; edtMatZal.Text := '0'; edtMatMin.Text := '0';
  lblMatErr.Text := '';
  tcMain.ActiveTab := tiMatForm;
end;

procedure TfrmMain.btnSaveMatClick(Sender: TObject);
var Q: TFDQuery;
begin
  lblMatErr.Text := '';
  if Trim(edtMatNaziv.Text) = '' then begin lblMatErr.Text := 'Naziv je obavezan.'; Exit; end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := dmData.Conn;
    Q.SQL.Text :=
      'INSERT INTO MATERIJAL (MAT_NAZIV,MAT_TIP,MAT_JEDINICA,MAT_ZALIHA,MAT_MIN_ZAL) ' +
      'VALUES (:NAZ,:TIP,:JED,:ZAL,:MIN)';
    Q.ParamByName('NAZ').AsString := Trim(edtMatNaziv.Text);
    Q.ParamByName('TIP').AsString := cmbMatTip.Text;
    Q.ParamByName('JED').AsString := Trim(edtMatJed.Text);
    Q.ParamByName('ZAL').AsFloat  := StrToFloatDef(edtMatZal.Text, 0);
    Q.ParamByName('MIN').AsFloat  := StrToFloatDef(edtMatMin.Text, 0);
    Q.ExecSQL;
    dmData.CommitWork;
    LoadMagacin;
    tcMain.ActiveTab := tiMagacin;
  except
    on E: Exception do lblMatErr.Text := 'Greska: ' + E.Message;
  end;
  Q.Free;
end;

procedure TfrmMain.btnCancelMatClick(Sender: TObject);
begin
  tcMain.ActiveTab := tiMagacin;
end;

end.

