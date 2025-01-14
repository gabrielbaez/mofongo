# Commenting achievements
Achievement.create!([
  {
    name: 'First Comment',
    description: 'Made your first comment',
    badge_icon: '💭',
    points: 10,
    category: 'commenting'
  },
  {
    name: 'Active Commenter',
    description: 'Made 10 comments',
    badge_icon: '🗣️',
    points: 25,
    category: 'commenting'
  },
  {
    name: 'Comment Expert',
    description: 'Made 50 comments',
    badge_icon: '📢',
    points: 50,
    category: 'commenting'
  },
  {
    name: 'Comment Master',
    description: 'Made 100 comments',
    badge_icon: '🎭',
    points: 100,
    category: 'commenting'
  }
])

# Posting achievements
Achievement.create!([
  {
    name: 'First Post',
    description: 'Published your first blog post',
    badge_icon: '✍️',
    points: 20,
    category: 'posting'
  },
  {
    name: 'Regular Blogger',
    description: 'Published 5 blog posts',
    badge_icon: '📝',
    points: 50,
    category: 'posting'
  },
  {
    name: 'Prolific Writer',
    description: 'Published 20 blog posts',
    badge_icon: '📚',
    points: 100,
    category: 'posting'
  },
  {
    name: 'Blog Master',
    description: 'Published 50 blog posts',
    badge_icon: '🎯',
    points: 200,
    category: 'posting'
  }
])

# Engagement achievements
Achievement.create!([
  {
    name: 'First Vote',
    description: 'Cast your first vote',
    badge_icon: '👍',
    points: 5,
    category: 'engagement'
  },
  {
    name: 'Active Voter',
    description: 'Cast 10 votes',
    badge_icon: '🗳️',
    points: 15,
    category: 'engagement'
  },
  {
    name: 'Super Voter',
    description: 'Cast 50 votes',
    badge_icon: '⭐',
    points: 30,
    category: 'engagement'
  },
  {
    name: 'Vote Master',
    description: 'Cast 100 votes',
    badge_icon: '🌟',
    points: 60,
    category: 'engagement'
  }
])

# Reputation achievements
Achievement.create!([
  {
    name: 'Rising Star',
    description: 'Earned 10 total points from comments',
    badge_icon: '🌱',
    points: 20,
    category: 'reputation'
  },
  {
    name: 'Community Favorite',
    description: 'Earned 50 total points from comments',
    badge_icon: '🌟',
    points: 50,
    category: 'reputation'
  },
  {
    name: 'Top Contributor',
    description: 'Earned 200 total points from comments',
    badge_icon: '🏆',
    points: 100,
    category: 'reputation'
  },
  {
    name: 'Legend',
    description: 'Earned 1000 total points from comments',
    badge_icon: '👑',
    points: 500,
    category: 'reputation'
  }
])
