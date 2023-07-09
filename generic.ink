=== function state_to(ref stateVariable, stateToReach)
	// remove all states of this type
	~ stateVariable -= LIST_ALL(stateToReach)
	// put back the state we want
	~ stateVariable += stateToReach

=== function pop(ref list)
   ~ temp x = LIST_MIN(list) 
   ~ list -= x 
   ~ return x

=== function pop_matching(ref list, matching)
   ~ temp x = LIST_MIN(list ^ matching) 
   ~ list -= x 
   ~ return x

=== function a(x)
    ~ temp stringWithStartMarker = "^" + x
    { stringWithStartMarker ? "^a" or stringWithStartMarker ? "^A" or stringWithStartMarker ? "^e" or  stringWithStartMarker ? "^E"  or stringWithStartMarker ? "^i" or stringWithStartMarker ? "^I"  or stringWithStartMarker ? "^o" or stringWithStartMarker ? "^O" or stringWithStartMarker ? "^u"  or stringWithStartMarker ? "^U"  :
            ~ return "an {x}"
            
    // this could be extended to check for "^hi" if you wanted "an historic..."            
    - else:
        ~ return "a {x}"
    }

=== function which(state, list)
    ~ return state ^ LIST_ALL(list)
    
/*
	Takes a list and prints it out, using commas. 

	Dependenices: 

		This function relies on the "pop" function. 

	Usage: 

		LIST fruitBowl = (apples), (bananas), (oranges)

		The fruit bowl contains {list_with_commas(fruitBowl)}.
*/
=== function list_with_commas(list)
	{ list:
		{_list_with_commas(list, LIST_COUNT(list))}
	- else: nothing
	}

=== function _list_with_commas(list, n)
	{pop(list)}{ n > 1:{n == 2: and |, }{_list_with_commas(list, n-1)}}

	
/*
    Converts a number between -1,000,000,000 and 1,000,000,000 into its printed (integer) equivalent.

    Usage: 

    There are {print_number(RANDOM(100000,10000000))} stars in the sky.

    Pi is roughly {print_number(3.1417)}.

*/
=== function print_number(x) 
~ x = INT(x) // cast to an int, since this function can only handle ints!
{
    - x >= 1000000:
        ~ temp k = x mod 1000000
        {print_number((x - k) / 1000000)} million{ k > 0:{k < 100: and|{x mod 100 != 0:<>,}} {print_number(k)}}
    - x >= 1000:
        ~ temp y = x mod 1000
        {print_number((x - y) / 1000)} thousand{ y > 0:{y < 100: and|{x mod 100 != 0:<>,}} {print_number(y)}}
    - x >= 100:
        ~ temp z = x mod 100
        {print_number((x - z) / 100)} hundred{z > 0: and {print_number(z)}}
    - x == 0:
        zero
    - x < 0: 
        minus {print_number(-1 * x)}
    - else:
        { x >= 20:
            { x / 10:
                - 2: twenty
                - 3: thirty
                - 4: forty
                - 5: fifty
                - 6: sixty
                - 7: seventy
                - 8: eighty
                - 9: ninety
            }
            { x mod 10 > 0:
                <>-<>
            }
        }
        { x < 10 || x > 20:
            { x mod 10:
                - 1: one
                - 2: two
                - 3: three
                - 4: four
                - 5: five
                - 6: six
                - 7: seven
                - 8: eight
                - 9: nine
            }
        - else:
            { x:
                - 10: ten
                - 11: eleven
                - 12: twelve
                - 13: thirteen
                - 14: fourteen
                - 15: fifteen
                - 16: sixteen
                - 17: seventeen
                - 18: eighteen
                - 19: nineteen
            }
        }
}
// remind me to submit a pull request fixing the default snippet's hundreds spacing


=== function print_number_capitalised(x) 
~ x = INT(x) // cast to an int, since this function can only handle ints!
{
    - x >= 1000000:
        ~ temp k = x mod 1000000
        {print_number_capitalised((x - k) / 1000000)} million{ k > 0:{k < 100: and|{x mod 100 != 0:<>,}} {print_number(k)}}
    - x >= 1000:
        ~ temp y = x mod 1000
        {print_number_capitalised((x - y) / 1000)} thousand{ y > 0:{y < 100: and|{x mod 100 != 0:<>,}} {print_number(y)}}
    - x >= 100:
        ~ temp z = x mod 100
        {print_number_capitalised((x - z) / 100)} hundred{z > 0: and {print_number(z)}}
    - x == 0:
        zero
    - x < 0: 
        Minus {print_number(-1 * x)}
    - else:
        { x >= 20:
            { x / 10:
                - 2: Twenty
                - 3: Thirty
                - 4: Forty
                - 5: Fifty
                - 6: Sixty
                - 7: Seventy
                - 8: Eighty
                - 9: Ninety
            }
            { x mod 10 > 0:
                <>-<>
            }
        }
        { x < 10 || x > 20:
            { x mod 10:
                - 1: One
                - 2: Two
                - 3: Three
                - 4: Four
                - 5: Five
                - 6: Six
                - 7: Seven
                - 8: Eight
                - 9: Nine
            }
        - else:
            { x:
                - 10: Ten
                - 11: Eleven
                - 12: Twelve
                - 13: Thirteen
                - 14: Fourteen
                - 15: Fifteen
                - 16: Sixteen
                - 17: Seventeen
                - 18: Eighteen
                - 19: Nineteen
            }
        }
} 

/*
	Tests if the flow passes a particular gather on this turn.

	Usage: 

	- (welcome)
		"Welcome!"
	- (opts)
		*	{came_from(->welcome)}
			"Welcome to you!"
		*	"Er, what?"
			-> opts
		*	"Can we get on with it?"
		
*/

=== function came_from(-> x) 
    ~ return TURNS_SINCE(x) == 0

/*
	Tests if the flow passes a particular gather "very recently" - that is, within the last 3 turns.

	Usage: 

	- (welcome)
		"Welcome!"
	- (opts)
		*	{seen_very_recently(->welcome)}
			"Sorry, hello, yes."
		+	"Er, what?"
			-> opts
		*	"Can we get on with it?"
		
*/

=== function seen_very_recently(-> x)
    ~ return TURNS_SINCE(x) >= 0 && TURNS_SINCE(x) <= 3

/*
	Threads in a given flow as a tunnel, with a given location to tunnel back to. 

	If choices within this content are taken, they should end with a tunnel return (->->).

	Useful for "pasting in" the same block of optional content into multiple locations.

	Usage: 


	- (opts)
		<- thread_in_tunnel(-> eat_apple, -> opts)
		<- thread_in_tunnel(-> eat_banana, -> get_going)
		*	[ Leave hungry ]
			-> get_going

	=== get_going
		You leave. 
		-> END 

	=== eat_apple 
		*	[ Eat an apple ]
			You eat an apple. It doesn't help.
			->->

	=== eat_banana 
		*	[ Eat a banana ]
			You eat a banana. It's very satisfying.
			->->
		
		
*/