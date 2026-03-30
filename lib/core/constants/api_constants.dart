/// LeetCode API constants — ported from leetcode-bot/config.py
abstract final class ApiConstants {
  static const leetcodeGraphqlUrl = 'https://leetcode.com/graphql';
  static const leetcodeBaseUrl = 'https://leetcode.com';

  static const userProfileQuery = r'''
query getUserProfile($username: String!) {
  matchedUser(username: $username) {
    username
    submitStats: submitStatsGlobal {
      acSubmissionNum {
        difficulty
        count
      }
    }
  }
  recentSubmissionList(username: $username, limit: 50) {
    title
    titleSlug
    timestamp
    statusDisplay
  }
}
''';

  static const problemsQuery = r'''
query ($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionListFilterInput) {
  problemsetQuestionList: questionList(
    categorySlug: $categorySlug
    limit: $limit
    skip: $skip
    filters: $filters
  ) {
    total: totalNum
    questions: data {
      acRate
      difficulty
      questionFrontendId
      isPaidOnly
      title
      titleSlug
      topicTags {
        name
        slug
      }
    }
  }
}
''';

  static const problemDetailQuery = r'''
query ($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    questionId
    questionFrontendId
    title
    titleSlug
    content
    difficulty
    likes
    dislikes
    topicTags {
      name
      slug
    }
    hints
    isPaidOnly
    exampleTestcases
    stats
    codeSnippets {
      lang
      langSlug
      code
    }
  }
}
''';

  static const dailyChallengeQuery = r'''
query {
  activeDailyCodingChallengeQuestion {
    date
    link
    question {
      questionFrontendId
      title
      titleSlug
      content
      difficulty
      topicTags {
        name
        slug
      }
      isPaidOnly
      hints
    }
  }
}
''';

  static const globalDataQuery = r'''
query {
  userStatus {
    username
    isSignedIn
  }
}
''';

  static const problemStatusQuery = r'''
query ($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    status
  }
}
''';

  static const recentAcSubmissionsQuery = r'''
query recentAcSubmissionList($username: String!, $limit: Int!) {
  recentAcSubmissionList(username: $username, limit: $limit) {
    id
    title
    titleSlug
    timestamp
  }
}
''';
}
