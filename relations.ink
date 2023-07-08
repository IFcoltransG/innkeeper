/*
MIT License

Copyright (c) 2017 inkle Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

// https://gist.github.com/joningold/6f3e8c4d7740de42c79a227a77baa8cf
// Code on the Inkle Patreon is licensed under MIT by Jon Ingold via the Inkle Discord.

~ relate(Key, MadeOf, Copper)
~ relate((Padlock, Spear), MadeOf, Iron) 
~ relate(GoldCoin, MadeOf, Gold)

VAR Inventory = () 

- (top) 
    *   [Pick up the {whatIs(Key, MadeOf)} key ] 
        ~ Inventory += Key
    *   [ Pick up the {whatIs(Padlock, MadeOf)} padlock] 
        ~ Inventory += Padlock
    *   [ Pick up the {whatIs(Spear, MadeOf)} spear ] 
        ~ Inventory += Spear
    *   [ Pick up the  {whatIs(GoldCoin, MadeOf)} coin]
        ~ Inventory += GoldCoin
-   You're now carrying: {Inventory}.
    +   [ Review gold ]
        ~ temp goldItems = whatIs(MadeOf, Gold) ^ Inventory     
        You have {goldItems:{goldItems}|nothing} made of gold.
    +   [ Review iron ] 
        ~ temp ironItems = whatIs(MadeOf, Iron)  ^ Inventory   
        You have {ironItems:{ironItems}|nothing} made of iron.
    +   [ List metals ] 
      You have items made of {whatIs(Inventory, MadeOf) }. 
    
-   -> top 


/*--------------------
    Game data
--------------------*/

LIST Items = Key, Padlock, GoldCoin, Spear 

LIST Metals = Copper , Gold , Iron

LIST Relations = MadeOf

// Tell ink which lists each relation links
=== function relationDatabase(rel, lhs)
    { rel: 
    -   MadeOf: 
            { lhs: 
                ~ return Items
            - else: 
                ~ return Metals
            }
    }
    
/*--------------------
    Standard utils
--------------------*/
    
    
=== function ITEM_IS_MEMBER_OF_LIST(k, list)
    ~ return k && LIST_ALL(list) ? k
    
=== function pop(ref list) 
    ~ temp x = LIST_MIN(list) 
    ~ list -= x 
    ~ return x 

/*--------------------
    Relation API
--------------------*/

=== function validate(x1, x2, rel) 
    { x1 && not ITEM_IS_MEMBER_OF_LIST(x1, relationDatabase(rel, true)):
        [ ERROR: {x1} not a valid lhs for {rel} ]
        ~ return false
    }
    { x2 && not ITEM_IS_MEMBER_OF_LIST(x2, relationDatabase(rel, false)):
        [ ERROR: {x2} not a valid rhs for {rel} ]
        ~ return false
    }
    ~ return true

=== function relate(x1, rel, x2) 
    { not validate(x1, x2, rel):
        ~ return ()
    }
    ~ _relate(x1, x2, rel) 
    
=== function unrelate(x1, rel, x2)  
    { validate(x1, x2, rel):
        // rebuild the whole pair string 
        ~ pairstore = _rebuildPairStringExcept(LIST_ALL(Relations), x1, x2, rel)
    }

=== function whatIs(a1, a2) 
    {
    - ITEM_IS_MEMBER_OF_LIST(a2, Relations): 
        ~ return getRelatesTo(a1, a2)
    - ITEM_IS_MEMBER_OF_LIST(a1, Relations): 
        ~ return getRelatedFrom(a2, a1)
    - else: 
        [ ERROR:    whatIs needs a relation!
    }

=== function getRelatesTo(x1, rel)
    { not validate(x1, (), rel):
        ~ return ()
    }
    ~ temp searchSpace = LIST_ALL(relationDatabase(rel, false))
    ~ return _getMatchedPairs(x1, searchSpace, rel, false)

=== function getRelatedFrom(x2, rel)
    { not validate((), x2, rel):
        ~ return ()
    }
    ~ temp searchSpace = LIST_ALL(relationDatabase(rel, true))
    ~ return _getMatchedPairs(searchSpace, x2, rel, true)

=== function isRelated(x1, x2, rel) 
    { validate(x1, x2, rel):
        {LIST_COUNT(x1) > 1 || LIST_COUNT(x2) > 1:
            [ERROR: Testing relation {rel} on non-unary lists {x1} and {x2} ] 
            ~ return false 
        }
        ~ return _isRelated(x1, x2, rel)  
    }

    
/*--------------------
    Internal datastore functions
--------------------*/    
    
VAR pairstore = ""    

=== function _isRelated(x1, x2, rel) 
    ~ temp relString = _pairString(x1, x2, rel)  
    ~ return pairstore ? relString
    
=== function _getMatchedPairs(list1, list2, rel, getLhs) 
    ~ temp ret = ()
    { LIST_COUNT(list1):
    - 0:    ~ return () 
    - 1:    ~ temp el2 = pop(list2) 
            { el2: 
                { _isRelated(list1, el2, rel): 
                    { getLhs: 
                        ~ ret = list1        
                    - else: 
                        ~ ret = el2 
                    }
                }
                ~ return ret + _getMatchedPairs(list1, list2, rel, getLhs) 
            }
            ~ return () 
    - else: 
            ~ temp el1 = pop(list1) 
            ~ return _getMatchedPairs(el1, list2, rel, getLhs) + _getMatchedPairs(list1, list2, rel, getLhs) 
    } 

=== function _pairString(x1, x2, rel) 
    ~ return ":{x1}>{rel}>{x2};"



=== function _relate(list1, list2, rel) 
    { LIST_COUNT(list1):
    - 0:    ~ return 
    - 1:    ~ temp el2 = pop(list2) 
            { el2: 
                { not _isRelated(list1, el2, rel): 
                    ~ pairstore += _pairString(list1, el2, rel) 
                }
                ~ return _relate(list1, list2, rel) 
            }
            ~ return () 
    - else: 
            ~ temp el1 = pop(list1) 
            ~ return _relate(el1, list2, rel) + _relate(list1, list2, rel) 
    }     
    
    
    
=== function _rebuildPairStringExcept(allRels, x1, x2, rel) 
    ~ temp relEl = pop (allRels) 
    {
    - not relEl: 
        ~ return ""
    - relEl == rel:
        ~ return _validPairsIn(LIST_ALL(relationDatabase(rel, true)), LIST_ALL(relationDatabase(rel, false)), relEl, x1, x2) + _rebuildPairStringExcept(allRels, x1, x2, rel) 
    - else:
        ~ return _validPairsIn(LIST_ALL(relationDatabase(relEl, true)), LIST_ALL(relationDatabase(relEl, false)), relEl, (), ()) + _rebuildPairStringExcept(allRels, x1, x2, rel) 
    }
    
=== function _validPairsIn(list1, list2, rel, not1, not2) 
    ~ temp ret = ""
    { LIST_COUNT(list1):
    - 0:    ~ return () 
    - 1:    ~ temp el2 = pop(list2) 
            { el2: 
                { _isRelated(list1, el2, rel) && not (not1 ? list1 && not2 ? el2): 
                    ~ ret = _pairString(list1, el2, rel)        
                }
                ~ return ret + _validPairsIn(list1, list2, rel, not1, not2) 
            }
            ~ return ""
    - else: 
            ~ temp el1 = pop(list1) 
            ~ return _validPairsIn(el1, list2, rel, not1, not2) + _validPairsIn(list1, list2, rel, not1, not2) 
    }  