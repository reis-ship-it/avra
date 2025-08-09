import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';
class AICommandProcessor {
  static String processCommand(String command, BuildContext context) {
    final lowerCommand = command.toLowerCase();

    // Create list commands
    if (lowerCommand.contains('create') && lowerCommand.contains('list')) {
      return _handleCreateList(command);
    }

    // Add spot to list commands
    if (lowerCommand.contains('add') &&
        (lowerCommand.contains('spot') || lowerCommand.contains('location'))) {
      return _handleAddSpotToList(command);
    }

    // Find/search commands
    if (lowerCommand.contains('find') ||
        lowerCommand.contains('search') ||
        lowerCommand.contains('show me')) {
      return _handleFindCommand(command);
    }

    // Event commands
    if (lowerCommand.contains('event') ||
        lowerCommand.contains('weekend') ||
        lowerCommand.contains('upcoming')) {
      return _handleEventCommand(command);
    }

    // User discovery commands
    if (lowerCommand.contains('user') || lowerCommand.contains('people')) {
      return _handleUserCommand(command);
    }

    // Discovery/help commands
    if (lowerCommand.contains('help') ||
        lowerCommand.contains('discover') ||
        lowerCommand.contains('new places')) {
      return _handleDiscoveryCommand(command);
    }

    // Trip/planning commands
    if (lowerCommand.contains('trip') ||
        lowerCommand.contains('plan') ||
        lowerCommand.contains('adventure')) {
      return _handleTripCommand(command);
    }

    // Trending/popular commands
    if (lowerCommand.contains('trending') || lowerCommand.contains('popular')) {
      return _handleTrendingCommand(command);
    }

    // Default response
    return _handleDefaultCommand(command);
  }

  static String _handleCreateList(String command) {
    // Extract list name from command
    String listName = '';
    if (command.contains('"')) {
      final start = command.indexOf('"') + 1;
      final end = command.lastIndexOf('"');
      if (start > 0 && end > start) {
        listName = command.substring(start, end);
      }
    } else if (command.contains('called')) {
      final parts = command.split('called');
      if (parts.length > 1) {
        listName = parts[1].trim();
      }
    } else if (command.contains('for')) {
      final parts = command.split('for');
      if (parts.length > 1) {
        listName = parts[1].trim();
      }
    }

    if (listName.isEmpty) {
      listName = 'New List';
    }

    return "I'll create a new list called \"$listName\" for you! The list has been created and is ready for you to add spots. You can now say things like \"Add Central Park to my $listName list\" or \"Find coffee shops to add to $listName\".";
  }

  static String _handleAddSpotToList(String command) {
    String spotName = '';
    String listName = '';

    // Extract spot name
    if (command.contains('add') && command.contains('to')) {
      final addIndex = command.indexOf('add');
      final toIndex = command.indexOf('to');
      if (addIndex < toIndex) {
        spotName = command.substring(addIndex + 4, toIndex).trim();
      }
    }

    // Extract list name
    if (command.contains('to my') && command.contains('list')) {
      final toMyIndex = command.indexOf('to my');
      final listIndex = command.indexOf('list', toMyIndex);
      if (toMyIndex < listIndex) {
        listName = command.substring(toMyIndex + 5, listIndex).trim();
      }
    }

    if (spotName.isEmpty) spotName = 'this location';
    if (listName.isEmpty) listName = 'your list';

    return "Perfect! I've added $spotName to your \"$listName\" list. The spot is now saved and you can view it anytime. You can also say \"Show me my $listName list\" to see all the spots you've added.";
  }

  static String _handleFindCommand(String command) {
    if (command.contains('restaurant') || command.contains('food')) {
      return "I found some great restaurants for you! Here are some recommendations: Joe's Pizza (casual), The French Laundry (fine dining), and Chelsea Market (food court). Would you like me to add any of these to a list or get more specific recommendations?";
    }

    if (command.contains('coffee') || command.contains('cafe')) {
      return "I found excellent coffee shops nearby! Try Blue Bottle Coffee, Stumptown Coffee Roasters, or Intelligentsia. All have great wifi and atmosphere. Would you like me to create a coffee shop list for you?";
    }

    if (command.contains('park') || command.contains('outdoor')) {
      return "I found beautiful outdoor spots! Central Park is always a classic, Prospect Park has great trails, and Brooklyn Bridge Park offers amazing views. Would you like me to add these to an outdoor spots list?";
    }

    if (command.contains('study') || command.contains('quiet')) {
      return "I found perfect study spots! Try the New York Public Library, Brooklyn Public Library, or quiet coffee shops like Think Coffee. All have good wifi and quiet atmosphere.";
    }

    return "I can help you find restaurants, coffee shops, parks, study spots, and more! Just tell me what you're looking for and I'll find the best options for you.";
  }

  static String _handleEventCommand(String command) {
    if (command.contains('weekend')) {
      return "Here are some great events this weekend: Brooklyn Flea Market (Saturday), Central Park Concert Series (Sunday), and Food Truck Festival (both days). Would you like me to create an events list for you?";
    }

    if (command.contains('upcoming')) {
      return "I found upcoming events: Jazz in the Park (next Friday), Art Walk (next Saturday), and Farmers Market (every Sunday). I can add these to your events list if you'd like!";
    }

    return "I can show you events happening this weekend, upcoming events, or help you discover new activities. What type of events are you interested in?";
  }

  static String _handleUserCommand(String command) {
    if (command.contains('hiking')) {
      return "I found users who love hiking! Sarah (likes mountain trails), Mike (prefers city parks), and Emma (adventure seeker). Would you like to connect with any of them?";
    }

    if (command.contains('area')) {
      return "I found users in your area! There are 15 users within 2 miles who share similar interests. Would you like me to show you their profiles or help you connect?";
    }

    return "I can help you find users with similar interests, users in your area, or help you discover new connections. What type of users are you looking for?";
  }

  static String _handleDiscoveryCommand(String command) {
    return "I'd love to help you discover new places! Based on your preferences, I recommend checking out: Brooklyn Bridge Park (amazing views), Chelsea Market (food paradise), and High Line (unique urban walk). Would you like me to create a discovery list for you?";
  }

  static String _handleTripCommand(String command) {
    return "I can help you plan an amazing trip! I'll create a comprehensive list with transportation, accommodation, activities, and local recommendations. What type of trip are you planning? Weekend getaway, city exploration, or outdoor adventure?";
  }

  static String _handleTrendingCommand(String command) {
    return "Here are the trending spots right now: Brooklyn Bridge Park (amazing sunset views), Chelsea Market (foodie paradise), and High Line (unique urban experience). These are getting lots of love from the community!";
  }

  static String _handleDefaultCommand(String command) {
    return "I can help you with many things! Try asking me to:\n• Create lists (\"Create a coffee shop list\")\n• Add spots (\"Add Central Park to my list\")\n• Find places (\"Find restaurants near me\")\n• Discover events (\"Show me weekend events\")\n• Find users (\"Find hikers in my area\")\n• Plan trips (\"Help me plan a weekend trip\")";
  }
}
