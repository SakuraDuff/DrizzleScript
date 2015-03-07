/*==========================================================
DrizzleScript v1.00
Created By: Ryhn Teardrop
Original Date: Dec 3rd, 2011
Last Modified: March 6th, 2015

Programming Contributors: Ryhn Teardrop, Brache Spyker
Resource Contributors: Murreki Fasching, Brache Spyker

License: RPL v1.5 (Outlined at http://www.opensource.org/licenses/RPL-1.5)

The license can also be found in the folder these scripts are distributed in.
Essentially, if you edit this script you have to publicly release the result.
(Copy/Mod/Trans on this script) This stipulation helps to grow the community and
the software together, so everyone has access to something potentially excellent.


*Leave this header here, but if you contribute, add your name to the list!*
============================================================*/

/* Script used to offer and manage setting-changing menu options */

integer g_PrintTextueLength;
integer g_PrintCardLength;
integer g_uniqueChan;
integer g_currCount;
string g_currMenu;
string g_currMenuMessage; //Potentially usable to determine which timer is being used?
list g_currMenuButtons;
list g_Skins;
list g_Printouts;
list g_SettingsMenu = ["★","★","Gender", "Skins","Chatter","Printouts", "Potty", "Interactions", "Volume"];
list g_GenderMenu = ["<--BACK", "★", "★", "Boy", "Girl"];
list g_ChatterMenu = ["<--BACK", "★", "★", "High", "Low", "Self"];
list g_VolumeMenu = ["<--BACK", "★", "★", "Crinkle❤Volume", "Wet❤Volume", "Mess❤Volume"];
list g_PottyMenu = ["<--BACK", "★", "★", "Wet❤Timer", "Mess❤Timer", "★", "Wet%", "Mess%", "★", "❤Tickle❤", "Tummy❤Rub", "★"];
list g_timerOptions = ["<--BACK", "★", "★", "40", "60", "120", "15", "20", "30", "0", "5", "10"]; // Backwards  (Ascending over 3) to make numbers have logical order.
list g_chanceOptions = ["<--BACK", "90%", "100%", "60%", "70%", "80%", "30%", "40%", "50%", "0%", "10%", "20%"]; // Backwards (Ascending over 3) to make numbers have logical order.
list g_InteractionsOptions = ["<--BACK","★", "★","Everyone","Carers❤&❤Me"];
/* For Misc Diaper Models */
integer g_mainPrim;
string g_mainPrimName = ""; // By default, set to "".

//Old variables used in my prim-sculptie based system.
//list g_Ruffles;
//list g_Panels;
//list g_TrainingMenu = ["<--BACK", "★", "★", "Infant", "Toddler", "Adult"];
//list g_Tapes;
//list g_ColorMenu = ["<--BACK", "★", "★", "Padding", "Ruffles", "Pins", "Cutesy", "Adult"];
//list g_AppearanceMenu = ["<--BACK", "★", "★", "Tapes", "Ruffles", "Color", "Skins", "Panel"];
//list g_ColorMenu = ["<--BACK", "★", "★"];


/*
    This function is customized to work with Zyriik's Puppy Pawz Pampers model.
    It assumes that the main model is named "Main Shape" and searches through the link set until it discovers it.
*/  
findPrims()
{
    
    if(g_mainPrimName == "") // No specified prim. Look for root.
    {
        g_mainPrim = 1;
    }
    else // Specified prim. Find it.
    {
        integer i; // Used to loop through the linked objects
        integer primCount = llGetNumberOfPrims(); //should be attached, not sat on
        for(i = 1; i <= primCount; i++)
        { 
            string primName = (string) llGetLinkPrimitiveParams(i, [PRIM_NAME]); // Get the name of linked object i
        
            if(g_mainPrimName == primName)  // Is this the prim?
            {
                g_mainPrim = i;
            }    
        }

    }
}


//@l = list of dialog options
//@readLocation = The index used to determine where to start reading the list
//@id = Key used to dispatch finished page
//---- This function generates the page to be displayed (This function curiously is used to display page 1)
integer prevPage(string MenuText, list l, integer readLocation, key id)
{
    if(readLocation < -1) return readLocation;
            
    readLocation -= 22; //Go back two pages (11 for current page, 11 more to get readLocation to the start of the page)
    
    if(readLocation == -1) //First page
    {
        //@temp = elements 0 through 9 in g_Skins, and then 10 and 11 are Help and Next-->
        list temp = ["Help", "NEXT-->"] + llList2List(l, readLocation+1, readLocation+10);
        readLocation += 11; // Moving the readLocation forward 11 elements is incorrect.
        
        offerMenu(id, MenuText, temp);
        
        return readLocation;       
    }
    else
    {
        list temp = ["Help", "<--PREV", "NEXT-->"] + llList2List(l, readLocation+1, readLocation+10);
        readLocation += 11;
        offerMenu(id, MenuText, temp);
        
        return readLocation;
    }
}

//@id = The key used to send the menu out.
//This function determines which page needs to be generated
handlePrev(key id)
{
   
    if(g_currMenu == "Skins")
    {
         g_currCount = prevPage("Choose a skin:",g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Printouts")
    {
        g_currCount = prevPage("Choose a Printout style:",g_Printouts, g_currCount, id);
    }
         
    /* Old code from prim-sculptie based build
    if(g_currMenu == "Tapes")
    {
        g_currCount = prevPage(g_Tapes, g_currCount, id);
    }
    else if(g_currMenu == "Ruffles")
    {
         g_currCount = prevPage(g_Ruffles, g_currCount, id);
    }
    else if(g_currMenu == "Color")
    {
    //     g_currCount = prevPage(g_Colors, g_currCount, id);
    }
    else if(g_currMenu == "Panel")
    {
         g_currCount = prevPage(g_Panels, g_currCount, id);
    }*/
}

//@l = list of dialog options
//@readLocation = The index used to determine where to start reading the list
//@id = Key used to dispatch finished page
//---- This function generates the page to be displayed
integer nextPage(string MenuText, list l, integer readLocation, key id)
{
    integer maxReadLocation = llGetListLength(l);
    integer i;
    list temp;
    list stars;
    
    if(readLocation > maxReadLocation) return readLocation; // Invalid readLocation
    if(readLocation+11 > maxReadLocation) //This is the last page, and it wont be full
    {
        temp = llList2List(l, readLocation, readLocation+10);
        readLocation += 11;
        
        integer numStars = 10 - (llGetListLength(temp)); // 10 stars leaves room for Help and <--PREV

       
        //Add the stars for filler
        for(i = 0; i < numStars; i++)
        {
            stars += ["★"];
        }
        
        temp = ["Help", "<--PREV"] + stars + temp;
        
        g_currMenuButtons = temp;
        offerMenu(id, MenuText, temp);
    }
    else // Full page.
    {
        temp = ["<--PREV","NEXT-->"] + llList2List(l, readLocation, readLocation+10); 
        readLocation += 11;
        offerMenu(id, MenuText, temp);
    }
    
    return readLocation;
}

//@id = The key used to send the menu out.
//This function determines which page needs to be generated
handleNext(key id)
{
    if(g_currMenu == "Skins")
    {
         g_currCount = nextPage("Choose a skin:",g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Printouts")
    {
        g_currCount = nextPage("Choose a Printout style:",g_Printouts, g_currCount, id);
    }
         
    /* Old code for a prim-based build.
    if(g_currMenu == "Tapes")
    {
        g_currCount = nextPage(g_Tapes, g_currCount, id);
    }
    else if(g_currMenu == "Skins")
    {
         g_currCount = nextPage(g_Skins, g_currCount, id);
    }
    else if(g_currMenu == "Ruffles")
    {
         g_currCount = nextPage(g_Ruffles, g_currCount, id);
    }
    else if(g_currMenu == "Colors")
    {
         g_currCount = nextPage(g_Colors, g_currCount, id);
    }
    else if(g_currMenu == "Panel")
    {
         g_currCount = nextPage(g_Panels, g_currCount, id);
    }
    */  
}

loadAllTextures(list l)
{
    integer i;
    
    for(i = 0; i < g_PrintTextueLength; i++)
    {
        string temp = llList2String(l, i);  //seems less confusing to just use llList2String than typecasting a single List2list entry...
        string prefix = llGetSubString(temp, 0, llSubStringIndex(temp, ":"));
        string name = llGetSubString(temp, llSubStringIndex(temp, ":") + 1, llStringLength(temp));
        
        if(prefix == "SKIN:")
        {
            g_Skins += name;  
        }
        //Add additional textures that need to be loaded for other diaper types here
    }
}

loadPrintouts(list l)
{
    integer i;
    
    for(i = 0; i < g_PrintCardLength; i++)
    {
        string temp = llList2String(l, i);
        string prefix = llGetSubString(temp, 0, llSubStringIndex(temp, ":"));
        string name = llGetSubString(temp, llSubStringIndex(temp, ":") + 1, llStringLength(temp));
        if(prefix == "PRINT:")
        {
            g_Printouts += name;
        }
    }
}

loadInventoryList()
{
    list result = [];
    integer n = llGetInventoryNumber(INVENTORY_TEXTURE);
    
    while(n)
    {
        result = llGetInventoryName(INVENTORY_TEXTURE, --n) + result;
    }
    g_PrintTextueLength = llGetListLength(result);
    
    loadAllTextures(result);
    
    result = [];
    n = llGetInventoryNumber(INVENTORY_NOTECARD);
    
    while(n)
    {
        result = llGetInventoryName(INVENTORY_NOTECARD, --n) + result;
    }
    g_PrintCardLength = llGetListLength(result);
    
    loadPrintouts(result);
    
}
integer generateChan(key id)
{
    string channel = "0xE" +  llGetSubString((string)id, 0, 6);
    return (integer) channel;
}

//Identical to llDialog except channel isn't passed, and
//this function tucks in a few lines of code to track the last menu accessed
offerMenu(key id, string dialogMessage, list buttons)
{
    g_currMenuButtons = buttons;
    g_currMenuMessage = dialogMessage;
    llDialog(id, dialogMessage, buttons,g_uniqueChan);   
}

handleMenuChoice(string msg, key id)
{

    /* Old code from a prim-sculptie based build.
    
    if(msg == "Tapes")
    {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_Tapes, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Choose a the tape texture you'd like: ", temp);
        g_currCount += 11;
    }
    else if(msg == "Panel")
    {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_Panels, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Choose a the panel texture you'd like: ", temp);
        g_currCount += 11;   
    }
    else if(msg == "Ruffles")
    {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_Ruffles, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Choose a panel texture you'd like: ", temp);
        //llDialog(id, "Choose a the panel texture you'd like: ", temp, g_uniqueChan);
        g_currCount += 11;   
    }
    else if(msg == "WetTex")
    {
        g_currMenu = msg;
        //Incomplete
    }
    else if(msg == "MessTex")
    {
        g_currMenu = msg;
        //Incomplete
    }
    else if(msg == "Colors")
    {
        g_currMenu = msg;
        g_currCount = -1;
        list temp = llList2List(g_ColorMenu, g_currCount+1, g_currCount+10) + ["NEXT-->", "HELP"];
        llSay(0, "Temp is: " + (string) temp);
        offerMenu(id, "Adjust your colors!", temp);
        g_currCount += 11;  
    }
    else if(msg == "Training")
    {
        g_currMenu = msg;
        g_currCount = -1;
        offerMenu(id, "How potty trained are you?", g_TrainingMenu);   
    }
    */
}

//@name = Texture name
//@prefix = Texture's type
applyTexture(string name, string prefix)
{
    string texture = prefix + name;
    vector repeats;
    vector offset;
    float radRotation;
    
    repeats.x = 1.0;
    repeats.y = 1.0;
    
    offset.x = 0.0;
    offset.y = 0.0;
    
    radRotation = 0.0;
    
    llSetLinkPrimitiveParamsFast(g_mainPrim, [PRIM_TEXTURE, ALL_SIDES, texture, repeats, offset, radRotation]);
}

integer contains(list l, string test)
{
    if(~llListFindList(l, [test])) // test found, it's in the list!
    {
        return TRUE;   
    }
    else return FALSE;
}

default
{
    
    state_entry()
    {
        g_uniqueChan = generateChan(llGetOwner()) + 1; // Remove collision with Menu listen handler via +1
        llListen(g_uniqueChan, "", "", "");
        loadInventoryList();
        findPrims();   
    }
    
    attach(key id)
    {
        if(id) // Attached
        {
            findPrims();    
        }
    }
    
    changed(integer change)
    {
        if(change & CHANGED_OWNER | CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }
    
    on_rez(integer start_param)
    {
        llResetScript(); 
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num != -1) return;
        
        if(msg == "Options")
        {
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
    }
    
    listen(integer chan, string name, key id, string msg)
    {
        if(msg == "★") // Someone misclicked in the menu!
        {
            llOwnerSay("The stars are just there to look pretty! =p");
            offerMenu(id, g_currMenuMessage, g_currMenuButtons);
        }
        else if(msg == "<--BACK")
        {
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(contains(g_Skins, msg) && g_currMenu == "Skins")
        {
            applyTexture(msg, "SKIN:");
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(contains(g_Printouts, msg)  && g_currMenu == "Printouts") // new printout notecard!
        {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY); //whew!
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "NEXT-->")
        {
            handleNext(id);
        }
        else if(msg == "<--PREV")
        {
            handlePrev(id);
        }
        else if(g_currMenu == "Crinkle❤Volume")
        {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "Wet❤Volume")
        {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "Mess❤Volume")
        {
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }            
        else if(g_currMenu == "Mess%")
        {
            //Mess%:10%
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "Wet%")
        {
            //Wet%:10%
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "Mess❤Timer")
        {
            //Mess❤Timer:10
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "Wet❤Timer")
        {
            //Wet❤Timer:10
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "❤Tickle❤")
        {
            //❤Tickle❤:??
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(g_currMenu == "Tummy❤Rub")
        {
            //Tummy❤Rub:??
            llMessageLinked(LINK_THIS, -3, g_currMenu + ":" + msg, NULL_KEY);
            g_currMenu = "";
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "Boy") //Sent to main to update values and pass to Printouts
        {
            llMessageLinked(LINK_THIS, -3, "Gender:0", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "Girl")
        {
            llMessageLinked(LINK_THIS, -3, "Gender:1", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        //Security settings
        else if(msg == "Everyone")
        {
            llMessageLinked(LINK_THIS, -3, "Others:1", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "Carers❤&❤Me")
        {
            llMessageLinked(LINK_THIS, -3, "Others:0", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        //chat spam level
        else if(msg == "High")
        {
            llMessageLinked(LINK_THIS, -3, "Chatter:2", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "Low")
        {
            llMessageLinked(LINK_THIS, -3, "Chatter:1", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "Self")
        {
            llMessageLinked(LINK_THIS, -3, "Chatter:0", NULL_KEY);
            offerMenu(id, "Adjust your settings!", g_SettingsMenu);
        }
        else if(msg == "Skins")
        {
            g_currMenu = msg;
            g_currCount = -1;
            list temp;
            
            if(llGetListLength(g_Skins) <= 11)
            {
                temp = ["Help"] + llList2List(g_Skins, g_currCount+1, g_currCount+11);
                g_currCount += 12; //g_currCount is now 11 (starts at -1)
            }
            else
            {
                temp = ["Help", "NEXT-->"] + llList2List(g_Skins, g_currCount+1, g_currCount+10); // This is a list of 10 skins
                g_currCount += 11; //g_currCount is now 10 (starts at -1)
            }
            offerMenu(id, "Choose a Skin:", temp);
        }   
        else if(msg == "Help")
        {
            if (g_currMenu == "Skins")
            {
                llOwnerSay("To add your own skins, simply prefix the name of a texture you want to add with:\n\nSKIN:\n\n. . . And drag it into your diaper!");
            }
            else if(g_currMenu == "Printouts")
            {
                llOwnerSay("To add new printout cards, simply prefix the name of a preformatted notecard you want to add with:\n\nPRINT:\n\n. . . And drag it into your diaper!");
            }
            llDialog(id, g_currMenuMessage, g_currMenuButtons, g_uniqueChan);
        }
        //todo: Merge changing of potty settings, volume settings, etc with main
        else if(msg == "Potty")
        {
            g_currMenu = msg;
            offerMenu(id, "Adjust your potty settings!", g_PottyMenu);  
        }
        else if(msg == "Volume")
        {
            g_currMenu = msg;
            offerMenu(id, "Adjust your volume settings!", g_VolumeMenu);  
        }
        else if(msg == "Mess❤Timer")
        {
            g_currMenu = msg;
            offerMenu(id, "Mess Frequency (How often you potty)\n\n==This is in Minutes==", g_timerOptions);   
        }
        else if(msg == "Wet❤Timer")
        {
            g_currMenu = msg;
            offerMenu(id, "Wet Frequency (How often you wet)\n\n==This is in Minutes==", g_timerOptions);   
        }
        else if(msg == "Wet%")
        {
            g_currMenu = msg;
            offerMenu(id, "Chance to hold it! (Wet)", g_chanceOptions);   
        }
        else if(msg == "Mess%")
        {
            g_currMenu = msg;
            offerMenu(id, "Chance to hold it! (Mess)", g_chanceOptions);   
        }
        else if(msg == "❤Tickle❤")
        {
            g_currMenu = msg;
            offerMenu(id, "Chance to resist tickles!", g_chanceOptions);   
        }
        else if(msg == "Tummy❤Rub")
        {
            g_currMenu = msg;
            offerMenu(id, "Chance to resist tummy rubs!", g_chanceOptions);   
        }
        else if(msg == "Printouts")
        {
            g_currMenu = msg;
            g_currCount = -1;
            list temp;
        
            if(llGetListLength(g_Printouts) <= 11)
            {
                temp = ["Help"] + llList2List(g_Printouts, g_currCount+1, g_currCount+11);
                g_currCount += 12; //g_currCount is now 11 (starts at -1)
            }
            else
            {
                temp = ["Help", "NEXT-->"] + llList2List(g_Printouts, g_currCount+1, g_currCount+10); // This is a list of 10 skins
                g_currCount += 11; //g_currCount is now 10 (starts at -1)
            }

            offerMenu(id, "Choose a Printout style:", temp);
        }
        else if(msg == "Gender")
        {
            g_currMenu = msg;
            offerMenu(id, "Are you a boy or a girl?", g_GenderMenu);   
        }
        else if(msg == "Interactions")
        {
            g_currMenu = msg;
            offerMenu(id, "Who should be able to interact with this diaper?", g_InteractionsOptions);
        }
        else if(msg == "Chatter")
        {
            g_currMenu = msg;
            offerMenu(id, "How far should the diaper chatter go?", g_ChatterMenu);
        }
        else if(msg == "Crinkle❤Volume")
        {
            g_currMenu = msg;
            offerMenu(id, "How loud should the crinkling be?", g_chanceOptions);
        }
        else if(msg == "Wet❤Volume")
        {
            g_currMenu = msg;
            offerMenu(id, "How loud should the wetting sound be?", g_chanceOptions);
        }
        else if(msg == "Mess❤Volume")
        {
            g_currMenu = msg;
            offerMenu(id, "How loud should the messing sound be?", g_chanceOptions);
        }
        else // Serve menu
        {
            handleMenuChoice(msg, id); //Creates the proper llDialog for the menu branch and sends it.
        }
    }
}
