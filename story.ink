# title: It Is An Innkeeper
# author: IFcoltransG

INCLUDE generic.ink
INCLUDE characters.ink


LIST time = (morning), meal, evening, night, closing
LIST player = innkeeper

VAR money = 0
VAR child = false
VAR looked_for_child = false

// locations (contains adventurers)
VAR wilderness = ()
VAR inn = ()
VAR skull_keep = ()
VAR dragon_cave = ()
VAR rat_dungeon = ()
VAR graveyard = ()

VAR new_deaths = ()
VAR new_survivals = ()

// items (who has them, including potentially innkeeper)
VAR wealth = ()
VAR l1_gear = ()
VAR l2_gear = ()
VAR l3_gear = ()

VAR debug = false
// VAR debug = true

It is an innkeeper.
There is gold it needs. It remembers, from its backstory, a family. The innkeeper needs gold for its family.
~ wilderness = LIST_ALL(characters)
-> new_day

// DAY

=== new_day
~ time = morning
~ looked_for_child = false
~ wealth = ()
->repel_adventurers(dragon_cave, 2, 3)->
->repel_adventurers(skull_keep, 1, 2)->
->repel_adventurers(rat_dungeon, 0, 1)->
The innkeeper {~wakes|awakes|awakes|wakes up|opens its eyes} <>
{at nine in the morning like clockwork.|at nine in the morning. Like yesterday. Like the day before. Like every day.|at nine o'clock.|.} <>
{~The weather is cloudy through|The sky is clear outside|Rain patters against|Mist fogs up} the window.
{debug: Debug, skull keep: {skull_keep}, rat dungeon: {rat_dungeon}, dragon cave: {dragon_cave}, graveyard: {graveyard}}
-> woken_up

// deaths in the night
= repel_adventurers(ref location, danger, loot)
~ temp loot_left = loot
{location ^ LIST_ALL(characters): ->repel_one_adventurer(location, danger, loot_left)->repel_adventurers(location, danger-1, loot_left)->}
->->

= repel_one_adventurer(ref location, danger, ref loot_left)
~ temp adventurer = pop_matching(location, LIST_ALL(characters))
~ location -= adventurer
{RANDOM(0, level(adventurer) * 3) >= RANDOM(0, danger * 3):
    ~ inn += adventurer
    ~ new_survivals += adventurer
    ~ wealth += adventurer
    { loot_left:
        - 0:
        - 1:
            ~ l1_gear += adventurer
        - 2:
            ~ l2_gear += adventurer
        - 3:
            ~ l3_gear += adventurer
    }
    ~ loot_left = 0
- else:
    ~ graveyard += adventurer
    ~ new_deaths += adventurer
}
->->

= woken_up
+ It opens the bar. -> just_opened
* It looks closer at the window.
    It places one hand on the wooden frame. The innkeeper's eyes scan the morning.
    It removes the hand and steps away.
    -> woken_up
* {menu} It reminisces.
It has a past. In the innkeepers backstory, a child plays in the rubble of a house. The child waves its small arms. The innkeeper waves back. There is nobody waving at the innkeeper outside the window.
The innkeeper needs gold. The innkeeper needs gold for its small child.
~ child = true
    -> woken_up
+ {money} It counts its coins.
    {print_number_capitalised(money)}.
    {child: Not enough.}
    + + It opens the bar. -> just_opened

=== just_opened
{LIST_COUNT(new_survivals):
- 0: 
- 1: {pop(new_survivals)} has returned{~||, bloodied|, unscathed|, alive|, although they almost did not}.
- else: {list_with_commas(new_survivals)} have returned{~||, alive|, traipsing blood on its floors}.
}
~ new_survivals = ()
-> menu
    
=== menu
{ time != closing:
    <- activities
    ->list_choices(-> adventurer_choice, inn)->
- else: Closing time. Time to close. Time to sleep.
}
    + [It closes the bar{(morning, meal) ? time: early}.] It closes the bar and goes to sleep.
        -> new_day
- -> menu


// LOOP

=== activities
The inn is {~crowded|full|packed}. {time:
- morning: <>Daytime.<>
- meal: <>Mealtime.<>
- evening: <>Eveningtime.<>
- night: <>Nighttime.<>
} Time to work. Patrons.
~ temp watched = came_from(-> watch_patrons)
+ {not watched} It watches the patrons.
    -> watch_patrons
+ It listens to the faces speaking to it at the bar.
    ~ time++
    ->random_adventurer->
- -> menu

= watch_patrons
{
    - inn:
        It sees many faces. {And it|It} sees {list_with_commas(inn)}.
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

= random_adventurer
    ~ temp new_adventurer = LIST_RANDOM(wilderness)
    ~ wilderness -= new_adventurer
    ~ inn += new_adventurer
    {new_adventurer} is a new face in town. <>
    ->news_from(new_adventurer)->->



=== adventurer_choice(adventurer)
+ [It {~brings|takes} {&a drink|refreshments|a meal|a flagon of water} to {adventurer}.]It approaches {adventurer} with a refreshing offering.
    ->news_from(adventurer)->
    + + It shares a rumour of a {~far-off|distant} {~locale|location|site|place} with {adventurer}.
    + + + It tells them of the small Rat Dungeon.
        {adventurer} listens intently to its description of a basement full of rats beneath the old shrine.
        ->share_rumour(adventurer, rat_dungeon)
    + + + It tells them of Skull Keep.
        {adventurer} listens raptly to its tale of Skull Keep, and the strange creatures therein.
        ->share_rumour(adventurer, skull_keep)
    + + + It tells them of the deadly Dragon Cave.
        {adventurer} listens fearfully to its warning never to set foot in the dangerous cavern, for though it be chock full of riches, no traveller returns.
        ->share_rumour(adventurer, dragon_cave)
    + + + It shakes its head, and returns to the bar without gossiping.
        {adventurer} cannot hide their disappointment.
    + + It offers to take any {~unwanted|unneeded} {~equipment|weapons and armour} off their hands.
        ~ time++
    + + It offers them {~superior|premium} {~equipment|weapons and armour}. For a price.
        ->offer_upgrade(adventurer)
    + + It steps back behind the bar.
- -> menu

= offer_upgrade(adventurer)
    ~ time++
    { level(adventurer):
    - 0:
        ~ l1_gear += adventurer
    - 1:
        ~ l2_gear += adventurer
    - 2:
        ~ l3_gear += adventurer
    - 3:
        They laugh. They simply laugh.
        // undo time wasting
        ~ time--
        * It asks what they are doing with their mough and lungs to make that sound.
            They reply their own equipment is already the finest in the land. Waste of breath.
            + + It returns to the bar.
            -> menu
    }
-> menu

= share_rumour(adventurer, ref location)
    ~ time++
    Their eyes widen at its promise of adventure and treasure unimaginable.
    ~ temp winnings = helped()
    Pulling their {~cloak over their shoulders|coat around their shoulders|robe over their clothes|hood over their head}, {adventurer} leaves its inn.
    ->count_coins(winnings)->
    ~ inn -= adventurer
    ~ location += adventurer
    -> menu

=== news_from(adventurer)
{debug: Debug: level {print_number(level(adventurer))}.}
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
    - wealth ? adventurer: {adventurer} recounts a recent victory, and the gold hoard they found there.
    - else: {shuffle:
        - {adventurer} stares at the bottom of their drink.
            ->->
        - {adventurer} looks at the innkeeper. It looks back at them.
            ->->
        - {adventurer}'s hands shake. The innkeeper steadily pours them a drink.
            ->->
        - {adventurer} speaks out of turn about the establishment. The innkeeper spills their drink.
            ->->
        - {adventurer} boasts of their prowess in battle.
        - {adventurer} tries to flirt with the innkeeper. It does not feel any more special.
        - {adventurer} {asks|questions it|asks it|asks the innkeeper} about the local facilities.
        - {adventurer} {asks|questions it|asks it|asks the innkeeper} about the local wildlife.
        - {adventurer} {asks|questions it|asks it|asks the innkeeper} about towns nearby.
        - {adventurer} {asks|questions it|asks it|asks the innkeeper} about local history.
    } <> {They seem to be satisfied by how the innkeeper responds.|Yes, they seem satisfied by the response.|}
}
->->


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

=== function goal
    {~glory|adventure|destiny|riches}

=== function level(adventurer)
    {
    - l3_gear ? adventurer:
        ~ return 3
    - l2_gear ? adventurer:
        ~ return 2
    - l1_gear ? adventurer:
        ~ return 1
    - else:
        ~ return 0
    }

// === function name_of(thing)
//     ~ temp description = ""
//     ~ temp name = ""
//     { thing:
//         - hat:
//             ~ return "{~a worn|an old|a mangy} wide-brimmed hat"
//         - helmet:
//             ~ return "an iron helmet"
//         - magic_helmet:
//             ~ description = "the {~magical|enchanted} helm"
//             ~ name = "Hardcap"
//             ~ return "{~{description} {name}|{name}, {description}}"
//         - club:
//             ~ return "{~a worn|an old|a brittle} wooden club"
//         - sword:
//             ~ return "{a sharp|a keen|a|a blunting|an old} steel shortsword"
//         - magic_sword:
//             ~ description = "the {~magical|enchanted} sword"
//             ~ name = "Painful"
//             ~ return "{~{description} {name}|{name}, {description}}"
//     }
//     ~ return "{a(thing)}"
