# title: It Is An Innkeeper
# author: IFcoltransG

INCLUDE generic.ink
INCLUDE characters.ink


LIST time = (morning), meal, evening, night, closing
LIST player = innkeeper

VAR money = 0
LIST rumours = gy, (rd), sk, dc, fs
VAR dreams = ()
VAR buy_percent = 50
VAR sell_percent = 150

VAR child = false
VAR looked_for_child = false
VAR certainty = false

VAR previous_time = morning

// locations (contains adventurers)
VAR wilderness = ()
VAR inn = (innkeeper)
VAR rat_dungeon = (rd)
VAR skull_keep = (sk)
VAR dragon_cave = (dc)
VAR frigid_south = (fs)
VAR graveyard = (gy)

VAR new_deaths = ()
VAR new_survivals = ()
VAR thankful = ()

// items (who has them, including potentially innkeeper)
VAR wealth = ()
VAR l1_gear = ()
VAR l2_gear = ()
VAR l3_gear = ()
VAR l4_gear = ()

// VAR debug = false
VAR debug = true

{debug:
    ~ SEED_RANDOM(47)
}


It is an innkeeper.
There is gold it needs. It remembers, from its backstory, a family. The innkeeper needs gold for its family.
~ wilderness = LIST_ALL(characters)
-> new_day

// DAY

=== new_day
~ time = morning
~ looked_for_child = false
~ wealth = ()
->repel_adventurers(frigid_south, 4, 4)->
->repel_adventurers(dragon_cave, 2, 3)->
->repel_adventurers(skull_keep, 1, 2)->
->repel_adventurers(rat_dungeon, 0, 1)->
The innkeeper {~wakes|awakes|awakes|wakes up|opens its eyes}{dreams ? fs: crying, but it does not know why}<>
{<> at nine in the morning like clockwork.|<> at nine in the morning. Like yesterday. Like the day before. Like every day.|<> at nine o'clock.|.} <>
{
- dreams ? fs: Snow piles up against the window.
- else: {~The weather is cloudy through|The sky is clear outside|Rain patters against|Mist fogs up} the window.
}
{debug: Debug, skull keep: {skull_keep}, rat dungeon: {rat_dungeon}, dragon cave: {dragon_cave}, graveyard: {graveyard}}
-> woken_up

// deaths in the night
= repel_adventurers(ref location, danger, loot)
~ temp loot_left = loot
{location ^ LIST_ALL(characters): ->repel_one_adventurer(location, danger, loot_left)->repel_adventurers(location, danger-1, loot_left)->}
->->

= repel_one_adventurer(ref location, danger, ref loot_left)
~ temp adventurer = pop_matching(location, LIST_ALL(characters))
~ temp lvl = level(adventurer)
~ temp survived = false
~ location -= adventurer
{ danger > 0:
    {
    - danger == lvl + 1:
        //  1/5 survival chance
        ~ survived = RANDOM(1, 5) == 1
    - danger == lvl - 1:
        // 4/5 survival
        ~ survived = RANDOM(1, 5) != 1
    - danger == lvl:
        // 2/3 survival
        ~ survived = RANDOM(1, 3) != 1
    - danger < lvl:
        // 14/15 survival
        ~ survived = RANDOM(1, 15) != 1
    - else:
        // 1/15 survival
        ~ survived = RANDOM(1, 15) == 1
    }
- else:
    ~ survived = true
}
{ survived:
    ~ inn += adventurer
    ~ new_survivals += adventurer
    ~ wealth += adventurer
    ~ thankful += adventurer
    // dream of conquering the location
    ~ dreams += LIST_ALL(rumours) ^ location
    { loot_left:
        - 0:
        - 1:
            ~ l1_gear += adventurer
        - 2:
            ~ l2_gear += adventurer
        - 3:
            ~ l3_gear += adventurer
        - 4:
            ~ l4_gear += adventurer
    }
    ~ loot_left = 0
- else:
    ~ graveyard += adventurer
    ~ new_deaths += adventurer
    { loot_left < lvl:
        // they died here, so any other adventurer has a chance of claiming their good loot
        ~ lose_gear(adventurer, lvl)
        ~ loot_left = lvl
    }
}
->->

= woken_up
+ It opens the bar.[] {It is an innkeeper, after all.|} -> just_opened
+ {menu && dreams !? fs} It plots how to acquire the gold it needs.[] -> tutorial
* It looks closer at the window.
    The innkeeper places one hand on the wooden frame. Its eyes scan the morning.
    It removes the hand and steps away.
    -> woken_up
* It looks in the mirror.
    In the mirror is another innkeeper.
    -> woken_up
* {menu} It reminisces[.] about the past.
    It has a past. In the innkeepers backstory, a child plays in the rubble of a house. The child waves its small arms. The innkeeper waves back. There is nobody waving at the innkeeper outside the window.
    The innkeeper needs gold. The innkeeper needs gold for its small child.
    ~ child = true
    -> woken_up
+ {money} It counts its coins.
    {print_number_capitalised(money)}.
    {child: Not enough.}
    + + It opens the bar. -> just_opened
+ {level(innkeeper) > 0} It checks its inventory of weapons and armour.
    {has_level(innkeeper, 1): Hanging on the wall is a metal helmet and a sword.}
    {has_level(innkeeper, 2): Under the bar is magical piece of armour and an enchanted sword.}
    {has_level(innkeeper, 3): Under lock and key upstairs, lie {what_weapon(3)} and {what_helmet(3)}.}
    {has_level(innkeeper, 4): Never leaving the innkeeper's body are {what_weapon(4)} and {what_helmet(4)}.}
    + + It opens the bar. -> just_opened

= tutorial
    It has seen that passing travellers have gold. It knows that adventurers will part with vast amounts of their gold, to pay for better weapons, better armour. It also imagines adventurers would be willing to give it their second-hand weapons and armour, if they have already found better weapons and armour elsewhere to replace it with. <>
    - (tutorial_questions) Profit.
    It basks in the thought of selling precious armour, cheaply bought from other adventurers.
    + {not seen_very_recently(-> elsewhere)} It visualises where the weapons and armour come from[.], that 'elsewhere'. -> elsewhere
    + (rewards) {elsewhere && not seen_very_recently(-> rewards)} It thinks of the potential rewards.
        It is an innkeeper. It hears things, rumours of dungeons, which vary in their amount of danger—and rumours of treasure in each location equalling the danger.
        New treasure for adventurers means their old treasure becomes cheap. New treasure for adventurers means new dangers become appropriate.
        It wonders what far-off locations can be braved. It wonders how many adventurers will leave behind {child: children|families}. -> tutorial_questions
    + (thinks_child) {child && elsewhere && not seen_very_recently(-> thinks_child)} It thinks of its child.
        It has seen many adventurers go on quests. If it had a quest, it would quest for its child.
        It thinks of ice, then turns to happier thoughts. <>
        -> tutorial_questions
    + It knows what it needs.[] It knows what it needs to do.
    - -> woken_up

= elsewhere
    It recalls that weapons and armour can be found in crypts, caves, and other dangerous places of the world.
    It understands that heroes may die venturing into these places. It understands.
    It thinks heroes are marginally less likely to perish when they venture into places appropriate to their equipment. They may still die.
    +  It understands.
    Death. -> tutorial_questions

=== just_opened
{LIST_COUNT(new_survivals):
- 0: 
- 1: {pop(new_survivals)} has returned{~||, bloodied|, unscathed|, alive|, although they almost did not}.
- else: {list_with_commas(new_survivals)} have returned{~||, alive|, traipsing blood on its floors}.
}
~ new_survivals = ()
-> menu
    
=== menu
~ temp same_time = time == previous_time
~ previous_time = time
{ time != closing:
    <- activities(same_time)
    ->list_choices(-> adventurer_choice, inn)->
- else: Closing time. Time to close. Time to sleep.
}
    + [It closes the bar{(morning, meal) ? time: early}.] It closes the bar, climbs the stairs slowly, and goes to sleep.
        {dreams ? fs:
            ~ child = true
            ~ certainty = true
        }
        {child: {once: It dreams of its family. It dreams of its child. It dreams of gold.}}
        {dreams ? rd: {once: It dreams of rats' eyes in the darkness. It dreams of sudden light. Families of the vermin scurry away. It does not like rats, because it is an innkeeper. The rats will return for their families, because they are rats.}}
        {dreams ? sk: {once: It dreams of skulls. It dreams of cold white bone. Or the cold white of something else. A towering castle stands stands on a hill. It dreams a figure in armour opens the castle door. It dreams a great frost swallows the castle. It dreams of a frozen land.}}
        {dreams ? dc: {once: It dreams of scales interlocking like chainmail. It dreams of shining shapes, like gold coins. It dreams of an immense form of scales falling from the sky, wings pierced by a sword. It dreams of coins falling like snow. {child:Lastly, it dreams of its child.}}}
        {dreams ? fs: {once: The wind howls outside its window. The wind howls for something. The wind howls as if for something lost.}}
        {dreams ? fs: {once: It dreams of its child. It watches. It walks. Its child walks. Its child walks into the snow, receding until its silhouette turns white. It does not ever come back to the innkeeper outstretched arm. A fire-crowned figure emerges from the ice, carrying a sword dipped in nothingness, but they are not a face it recognises.}}
        {dreams ? gy: {once: It dreams of graves.}}
        -> new_day
- -> menu


// LOOP

=== activities(same_time)
{ time == night:
The inn is quietening. <>
- else: The inn is {~crowded|full|packed}. <>
}
->get_time(same_time)->
<> Time to work. Patrons.
~ temp watched = came_from(-> watch_patrons)
+ {not watched} It watches the patrons[.]{, some of whom are starting to approach the bar to share their troubles| some more|}.
    -> watch_patrons
+ {time != night} It listens to the faces speaking to it at the bar.
    ->listen->
    {time == night:Its stream of talkative faces is drying up for the night.|}
- -> menu

= get_time(same_time)
{time:
- morning: {same_time:Still daytime|Daytime}
- meal: {same_time:Still mealtime|Mealtime}
- evening: {same_time:Still eveningtime|Eveningtime}
- night: {same_time:Still nighttime|Nighttime}
}<>.
->->

= watch_patrons
{
    - inn ^ LIST_ALL(characters):
        It sees many faces. {And it|It} sees {list_with_commas(inn ^ LIST_ALL(characters))}.
    - child && not looked_for_child:
        ~ looked_for_child = true
        {stopping:
            - It thinks it sees its child. It does not. It has to look away from the crowd.
            - It peers at each face one by one, but does not find its child, or anyone else it recognises.
            - It sees only unfamiliar faces, but wonders if its child might rest itself in the inn someday.
            - It sees no one it recognises. The innkeeper has learnt to stop looking for its child.
            - ->unfamiliar->
        }
    - child: It will not find what it is looking for, not today.
    - else: ->unfamiliar->
    }
-> menu

= unfamiliar
{&It sees no one it recognises.|It does not recognise anyone.|It watches unfamiliar faces. They will be gone tomorrow.|It sees faces, but none it has seen before.}
->->

/*
Protagonist story.

I went to the innkeeper. It said to go to the Stalwart Peak. It told me there was a dragon.
I fought the dragon, and won its hoard. I came back and spent my gold on overpriced vambraces.
I sold my magical hat to the innkeeper, because I didn't need it anymore.




Actions
- Eavesdrop
- Buy/sell
- Send on quest

*/

= listen
~ time++
{ stopping:
- ->random_adventurer->
- Two regal patrons ask it for the inn's most expensive room, paying in gold sovereigns. <>
    ->count_coins(50)->
- ->random_location->
- ->random_adventurer->
 - {shuffle:
    - ->random_adventurer->
    - ->random_location->
    - ->lodger->
    }
}
->->

= random_adventurer
    {not wilderness:
        A strange chill enters the inn, as though someone should be here but is not. It wonders if there are any more adventurers.
        ->->
    }
    ~ temp new_adventurer = LIST_RANDOM(wilderness)
    {stopping:
        -
            ~ l1_gear += new_adventurer
        -
        -
            { RANDOM(0, 1):
                ~ l1_gear += new_adventurer
            }
    }
    ~ wilderness -= new_adventurer
    ~ inn += new_adventurer
    {new_adventurer} is a new face in town. <>
    ->news_from(new_adventurer)->->
    
= random_location
    {not LIST_INVERT(rumours):
        {stopping:
        - A cartographer loudly claims the entire continent has been charted, asking for anyone to please buy their maps.
            It wonders whether the cartographer is right, that every reach of the world has been explored. {child: It considers asking if the cartographer knows where to find its child, but something stops it. A slight chill, perhaps.}
            ->->
        - A cartographer mopes in a corner. <>
            ->random_adventurer->->
        }
            
    }
    ~ temp new_rumour = LIST_RANDOM(LIST_INVERT(rumours))
    ~ temp basic = (rd, sk, dc)
    // delay some rumours
    {(gy, fs) ? new_rumour && rumours !? basic:
        ~ new_rumour = LIST_RANDOM(basic ^ LIST_INVERT(rumours))
    }
    ~ rumours += new_rumour
    { new_rumour:
        - rd: A patron is covered in small bites. They complain. The source of their torment is a basement full of rats, which they curse with a raised, pocked fist. The rats are under a shrine, they tell it.
        - sk: A patron keeps one eye on the door as they warn it never to venture to Skull Keep, for the place is home to strange creatures. It asks them where Skull Keep may be found, so it can caution other patrons where not to travel. It asks whether the keep contains any treasure. It asks them the approximate size and weight of any creatures guarding the keep.
        - dc: A patron from another village requests lodgings, explaining their home had been lit ablaze by the dragon of the deadly Dragon Cave. It receives payment from them for the room. It receives coins scrounged from many different dominations, but each one is gold. ->count_coins(12)->
        - gy: A crying patron explains they want no sympathy, only to be served. They attribute their state to a gravestone visited this morning, and flowers laid.
            It remembers the graveyard.
        - fs: A haggard patron recounts their missing friend's voyage to the frigid south. When asked for directions, they repeat themselves.
            It asks whether other people have been lost in the icy south. {child:It is thinking of one in particular.|It does not quite know why it thought to ask this, but it knows something here is important.}
        - else: A strange vision strikes it, and it feels it has glimpsed a far-off place.
    }
    ->->

= lodger
    One patron wants lodgings. They pay it up-front. <> ->count_coins(RANDOM(8, 10))->
    ->->

=== adventurer_choice(adventurer)
{LIST_ALL(characters) !? adventurer: -> DONE}
~ temp lvl = level(adventurer)
+ [It {~brings|takes} {&a drink|refreshments|a meal|a flagon of water} to {adventurer}.]It approaches {adventurer} with a refreshing offering.
    ->news_from(adventurer)->
    * * {lvl == 4 && not certainty} It needs to ask something. It needs to ask.
        It asks them what the cold was like.
        No, it needs to ask them something else, but it does not yet know what. It cannot yet ask.
        It wants to ask. But it is scared to sleep.
        -> menu
    * * {lvl == 4 && certainty} It utters the question that burns its soul.[] It already knows the answer.
        It asks if {adventurer} has seen its child. It tells them of its backstory, of raising the child from small. When the innkeeper looks in the mirror, it only ever sees a bigger version of its child.
        A bigger... smaller innkeeper. Because that is what it is, the child. That is what the child is. It is an innkeeper.
        The child played in the rubble of an inn. The child wanted to provide for its family. The child wanted gold. The child found only snow. The innkeeper loves it—loved it. The innkeeper needs its child. All the world's gold. All the world. That is not as much as its child.
        The innkeeper shivers and steps closer to the fire. It asks again. It asks. It asks if they have seen its child.
            It is numb to {adventurer}'s response.
        * * * It closes the bar.
            -> END
    + + {wealth !? adventurer} It shares a rumour of a {~far-off|distant} {~locale|location|site|place} with {adventurer}.
    + + + {rumours ? rd} It tells them of the small Rat Dungeon.
        {adventurer} listens intently to its description of a basement full of rats beneath the old shrine.
        Their eyes widen at its promise of adventure and small treasure.
        It tells them of a secret cache of rusting yet robust weapons and armour. {adventurer} swears on {what_weapon(lvl)} they call their own, that they will {~triumph|survive|win}.
        ->danger_level(lvl, 0)->share_rumour(adventurer, rat_dungeon)
    + + + {rumours ? sk} It tells them of Skull Keep.
        {adventurer} listens raptly to its tale of Skull Keep, and the strange creatures therein.
        Their eyes widen at its promise of destiny, adventure and treasure unimaginable.
        It tells them of a secret alcove hiding a magical piece of armour. {adventurer} swears on {what_weapon(lvl)} they call their own, that they will {~triumph|survive|win}.
        ->danger_level(lvl, 1)->share_rumour(adventurer, skull_keep)
    + + + {rumours ? dc} It tells them of the deadly Dragon Cave.
        {adventurer} listens fearfully to its warning never to set foot in the dangerous cavern, for though it be chock full of riches, it also be full of dragons.
        Their eyes widen at its promise of adventure, destiny and glory. And treasure unimaginable.
        It tells them of a secret vault concealing a mythical sword. {adventurer} swears on {what_weapon(lvl)} they call their own, that they will {~triumph|survive|win}.
        ->danger_level(lvl, 2)->share_rumour(adventurer, dragon_cave)
    + + + {rumours ? fs} It tells them of the Frigid South, from whose bourn no traveler returns.
        {adventurer} listens petrified.
        Their eyes widen at its promise of death. Or perhaps victory.
        It tells them of snatches of whispers of rumours of terrible secrets beyond. {adventurer} holds close {what_helmet(lvl)} they call their own, and assures it they will return with a tale to tell.
        ->danger_level(lvl, 4)->share_rumour(adventurer, frigid_south)
    + + + It shakes its head, and returns to the bar without gossiping.
        {adventurer} cannot hide their disappointment.
        -> menu
    + + It offers to take any {~unwanted|unneeded} {~equipment|weapons and armour} off their hands.
        ->accept_waste(adventurer)
    + + It offers them {~superior|premium} {~equipment|weapons and armour}. For a price.
        -> offer_upgrade(adventurer)
    + + It steps back behind the bar.
        -> menu

= danger_level(lvl, danger)
{
- lvl > danger + 1: Probably easy. Probably.
- lvl > danger: Potentially easy. Potentially.
- lvl < danger - 1: Probably life-threatening. Probably life-ending.
- lvl < danger: Potentially life-threatening. Potentially life-ending.
- else: Potentially hard-fought. Potentially hard-won.
}
->->

= share_rumour(adventurer, ref location)
    ~ time++
    ~ temp winnings = helped()
    Pulling their {~cloak over their shoulders|coat around their shoulders|robe over their clothes|hood over their head}, {adventurer} leaves its inn.
    ->count_coins(winnings)->
    ~ inn -= adventurer
    ~ location += adventurer
    -> menu

= offer_upgrade(adventurer)
    ~ time++
    { level(adventurer):
    - 4:
        They laugh. They simply laugh.
        // undo time wasting
        ~ time--
        * It asks what they are doing with their mouth and lungs to make that sound.
            They reply their own equipment is already the finest in the land. Waste of breath.
            + + It returns to the bar.
            -> menu
        + It returns to the bar.
            -> menu
    - else:
        + It offers them its finest wares.
            ->offer_level(adventurer, 4)->offer_level(adventurer, 3)->offer_level(adventurer, 2)->offer_level(adventurer, 1)->
            Apparently it has no fine wares behind the bar. Nor economical, for that matter.
            ~ time--
            -> menu
        + It offers them its most economical wares.
            ->offer_level(adventurer, 1)->offer_level(adventurer, 2)->offer_level(adventurer, 3)->offer_level(adventurer, 4)->
            Apparently it has no economical wares under the bar. Nor fine, for that matter.
            ~ time--
            -> menu
        + It can think of no wares to proffer[.] and returns to the bar.
            ~ time--
            -> menu
    }
    -> DONE

= offer_level(adventurer, lvl)
~ temp wealthy = wealth ? adventurer
{ has_level(innkeeper, lvl):
    { lvl > level(adventurer):
        ~ gain_gear(adventurer, lvl)
        ~ lose_gear(innkeeper, lvl)
        ~ temp price = INT((random_worth(lvl) * sell_percent) / 100) + 2
        {wealthy:
            {adventurer}'s purse clinks with gold.
            ~ price = (price + 4) * 2
            ~ wealth -= adventurer
        }
        <> It sells them {what_weapon(lvl)}, and {what_helmet(lvl)} for <>
        ->rate_price(price, lvl)->
        <>. {wealthy: Their purse no longer clinks so much.}
        ->count_coins(price)->
        -> menu
    - else:
        ~ temp adjective = "{~pitying|vacant|blank|condescending|dismissive|frustrated}"
        It {~displays|brandishes|reveals|shows|retrieves|mentions|speaks of} {what_weapon(lvl)}, but {~{adventurer}'s eyes glaze over|{adventurer} looks {adjective}ly at it|{adventurer} shrugs|{adventurer} looks at it {adjective}ly|{adventurer} gives it {a(adjective)} look|{adventurer} shakes their head {adjective}ly}.
    }
}
->->

= accept_waste(adventurer)
~ temp result = -> fail
->sell(adventurer, 1, result)->
->sell(adventurer, 2, result)->
->sell(adventurer, 3, result)->
->sell(adventurer, 4, result)->
-> result(adventurer)

= sell(adventurer, gear_lvl, ref result)
~ temp lvl = level(adventurer)
{ lvl > gear_lvl && has_level(adventurer, gear_lvl):
    { has_level(innkeeper, gear_lvl): 
        They try to dispose of their {what_weapon(gear_lvl)}, but it already has one, and the same for their {what_helmet(gear_lvl)}.
    - else:
        ~ temp price = INT((random_worth(gear_lvl) * buy_percent) / 100) + 2
        {debug: Debug: gear level {gear_lvl}, price {price}, money {money}}
        They tell it they {~no longer need|have no more use for|have outgrown} {what_weapon(gear_lvl)}, nor do they {~want|need|require} {what_helmet(gear_lvl)} of theirs. After {~bartering|haggling|negotiating} {~fiercely|lazily|firmly|languidly|for the sake of it}, <>
        { price <= money:
            they part with their gear for <>
            ->rate_price(price, gear_lvl)->
            <>. It reaches into its pockets and counts the coins into {adventurer}'s hand. {print_number_capitalised(price)}.
            ~ lose_gear(adventurer, gear_lvl)
            ~ gain_gear(innkeeper, gear_lvl)
            ~ money -= price
        - else:
            they offer their final number, {print_number(price)}, <>
            ->rate_price(price, gear_lvl)->
            <>. It tries to {~imagine|picture|visualise} that many {~coins|gold coins|gold pieces}, but it does not have enough.
            {adventurer} enquires about nearby {~establishments|shops} {~which|who} deal in that {~variety|kind|sort|breed} of {gear_lvl > 1:powerful|dangerous} wares. ->response->
            ~ lose_gear(adventurer, gear_lvl)
        }
    }
    ~ result = -> success
}
->->

= rate_price(price, lvl)
    {
    - price > 100 * lvl:an extortionate price
    - price > 30 * lvl:a hefty price
    - price > 10 * lvl:a modest price
    - price > 2 * lvl:a low price
    - price * 2 > lvl:a pittance
    - else:a not unreasonable fee
    }
    ->->

= success(adventurer)
    ~ time++
    ~ thankful -= adventurer
    -> menu

= fail(adventurer)
    ~ temp lvl = level(adventurer)
    They look at their {what_weapon(lvl)}, then at their {what_helmet(lvl)}, then back at it. They tell it they need these to battle monsters, and would not part with that which they still need.
    {lvl == 1: It notices they are still in possession of a hat and wooden club under their finer armour, but it keeps silent.}
    {once: They look wistfully outside, and explain the itch for adventure and cached bounties. They cannot wait to seek their fortune, just as soon as they can pick up a new lead for a fresh quest. They wish aloud to find a buried prize someday soon, so they can retire this paltry equipment.}
    {thankful ? adventurer:
        ~ thankful -= adventurer
        They wrinkle their eyebrows. It receives an apology from them, about {adventurer}'s inability to provide it any unused equipment just yet. It also receives a small pouch as {&thanks|gratitude} for the tip-off.
        ->count_coins(RANDOM(5, 8))->
        <> It raises one eyebrow.
        {once: {adventurer} expects to return to the road soon, claiming they only stopped in the inn for information regarding locations in which to adventure. More dangerous locations—more powerful spoils.}
    }
    -> menu

=== function random_worth(lvl)
    ~ temp scale = lvl * lvl
    {shuffle:
        -
            ~ return RANDOM(1, 200 * scale)
        -
            ~ return RANDOM(1, 100 * scale)
        -
            ~ return RANDOM(1, 30 * scale)
        -
            ~ return RANDOM(1, 10 * scale)
        -
            ~ return RANDOM(1, 2 * scale)
        -
            ~ return RANDOM(1, scale)
    }

=== news_from(adventurer)
{debug: Debug: level {print_number(level(adventurer))}. Gear: w {has_level(adventurer, 0)} 1 {has_level(adventurer, 1)} 2 {has_level(adventurer, 2)} 3 {has_level(adventurer, 3)} 4 {has_level(adventurer, 4)}}
~ temp lvl = level(adventurer)
They {~sport|wear} {what_helmet(lvl)}, and {~carry|wield} {what_weapon(lvl)}.
{
    - new_deaths: {shuffle:
        - {adventurer} brings news of {pop(new_deaths)}'s tragic demise.
        - {adventurer} shares the sad tale of {pop(new_deaths)}'s death in battle against insurmountable odds.
        - {adventurer} tells it of the noble but ultimately meaningless sacrifice of {pop(new_deaths)}, battling insurmountable odds.
    } <> {once:
    - If only they had been better equipped.
    - If only they had a stronger weapon. If only their armour had not faltered.
    - According to {adventurer}, it's no one's fault but their own that they rushed into a deadly place unprepared.
    - They shake their head at the pity of it all.
    - They monologue about their own mortality. It cannot relate.
    }
    - lvl == 4: {{adventurer} has a faraway look in their eye, like glass or ice. Or like death.|{adventurer} hums to themselves, and the timbers of the inn hum too.|{adventurer}'s eyes have not slept. {adventurer} will never sleep again.|{adventurer} is made of time.}
    - wealth ? adventurer: {adventurer} recounts a recent victory, and the gold hoard they found there. They are eager for another quest, and will start looking tomorrow.
        {A restful inn for now.|}
    - else:
        ~ temp asks = "{asks|questions it|asks it|asks the innkeeper}"
        {shuffle:
            - {adventurer} stares at the bottom of their drink.
                ->->
            - {adventurer} looks at the innkeeper. It looks back at them.
                ->->
            - {adventurer}'s hands shake. The innkeeper steadily pours them a drink.
                ->->
            - {adventurer} speaks out of turn about the establishment. The innkeeper spills their drink.
                ->->
            - {adventurer} tries to hug the innkeeper without first asking, but does not succeed.
                ->->
            - {adventurer} boasts of their prowess in battle.
            - {adventurer} tries to flirt with the innkeeper. It does not feel any more special.
            - {adventurer} {asks} about the local facilities.
            - {adventurer} {asks} about the local wildlife.
            - {adventurer} {asks} about towns nearby.
            - {adventurer} {asks} about local history.
            - {child: {adventurer} laughs in a way that reminds it of its child. Then the moment is gone.| {adventurer} laughs a youthful laugh.}
        }<>
        ->response->
}
{lvl == 4: The innkeeper feels an urge to ask them something. A welling pressure. A pain. A pain behind the eyes.}
->->

=== response
{<> They seem to be satisfied by how the innkeeper responds.|<> Yes, they seem satisfied by the response.|}
->->

=== function what_weapon(lvl)
    { lvl: 
    - 0:
        ~ return a("{~worn|||old|brittle} {~yellowy |brown |grey ||}{~wooden ||}{~club|stick}")
    - 1:
        ~ return a("{sharp|keen||blunting|old} steel shortsword")
    - 2:
        ~ return a("{~magical|enchanted|white-hot|glowing|gleaming} {~ink-black|silvered|golden|soul-glass} sword")
    - 3:
        ~ return describe_name("Painful", praise("{~{~soul|blood}-drinker |long||}sword"))
    - 4:
        ~ return "a sharp tear in reality, through which it hurts to look"
    }
    ~ return "a weapon"

=== function what_helmet(lvl)
    { lvl: 
    - 0:
        ~ return a("{~worn|||old|mangy} {~red |green |blue ||}{~wide-brimmed ||}{~hat|cap}")
    - 1:
        ~ return a("{~iron|dull metal|bronze} helmet")
    - 2:
        ~ return a("{~magical|enchanted|glowing|glittering} helmet")
    - 3:
        ~ return describe_name("Hardcap", praise("{~bejeweled |jewel-encrusted ||}helm")) 
    - 4:
        ~ return "a helmet of pure fire, the purest fire"
    }
    ~ return "a helmet"

=== function describe_name(name, description)
    ~ return "{~{description} {name}|{name}, {description}}"

=== function praise(entity)
    ~ return "{~the {~fabled|legendary|mythic} {entity}|the {~transcendent |numinous |soul-{~kissed|touched} | | | }{entity} of {~fable|legend|myth}}"

=== list_choices(-> what_do, list)
{list:
    ->_list_choices(what_do, list, LIST_COUNT(list))->
}
->->


= _list_choices(-> what_do, list, n)
{list:
    <- what_do(pop(list))
    {n > 1: ->_list_choices(what_do, list, n-1)->}
}
->->

=== function helped
    {RANDOM(1, 6):
    - 6: Thanking it for its generous {~assistance|assistance|service}, they place a pile of gold coins on the counter.
        ~ return RANDOM(12, 18)
    - 5: Thanking it for its generous {~assistance|service|service}, they place a few gold coins {~on the counter|in its hand}.
        ~ return RANDOM(3, 9)
    - else:
        ~ return 0
    }

=== count_coins(winnings)
{winnings: It counts the coins one by one into its other hand. {(print_number_capitalised(winnings))}.}
~ money += winnings
->->

=== function level(adventurer)
    {
    - l4_gear ? adventurer:
        ~ return 4
    - l3_gear ? adventurer:
        ~ return 3
    - l2_gear ? adventurer:
        ~ return 2
    - l1_gear ? adventurer:
        ~ return 1
    - else:
        ~ return 0
    }

=== function is_level(adventurer, lvl)
    ~ return level(adventurer) == lvl

=== function has_level(adventurer, lvl)
    ~ temp gearlist = wealth
    { lvl:
    - 4:
        ~ gearlist = l4_gear
    - 3:
        ~ gearlist = l3_gear
    - 2:
        ~ gearlist = l2_gear
    - 1:
        ~ gearlist = l1_gear
    - else:
        ~ gearlist = wealth
    }
    ~ return gearlist ? adventurer

=== function lose_gear(adventurer, lvl)
    { lvl:
    - 4:
        ~ l4_gear -= adventurer
    - 3:
        ~ l3_gear -= adventurer
    - 2:
        ~ l2_gear -= adventurer
    - 1:
        ~ l1_gear -= adventurer
    - else:
        ~ wealth -= adventurer
    }

=== function gain_gear(adventurer, lvl)
    { lvl:
    - 4:
        ~ l4_gear += adventurer
    - 3:
        ~ l3_gear += adventurer
    - 2:
        ~ l2_gear += adventurer
    - 1:
        ~ l1_gear += adventurer
    - else:
        ~ wealth += adventurer
    }

