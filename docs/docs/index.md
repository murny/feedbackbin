---
layout: docs
title: Documentation
description: "Learn how to set up, configure, and use FeedbackBin to manage customer feedback effectively."
---

Welcome to the FeedbackBin documentation! Here you'll find everything you need to get started with our open-source feedback management platform.

## Quick Start

<div class="grid grid-cols-1 md:grid-cols-2 gap-6 my-8">
  <a href="{{ "/docs/getting-started/" | relative_url }}" class="block p-6 bg-card border border-border rounded-lg hover:shadow-md transition-shadow">
    <div class="flex items-center mb-4">
      <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mr-3">
        <svg class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5.25 5.653c0-.856.917-1.398 1.667-.986l11.54 6.348a1.125 1.125 0 010 1.971l-11.54 6.347a1.125 1.125 0 01-1.667-.985V5.653z" />
        </svg>
      </div>
      <h3 class="text-lg font-semibold">Getting Started</h3>
    </div>
    <p class="text-muted-foreground">Installation, configuration, and first steps with FeedbackBin.</p>
  </a>

  <a href="{{ "/docs/guides/" | relative_url }}" class="block p-6 bg-card border border-border rounded-lg hover:shadow-md transition-shadow">
    <div class="flex items-center mb-4">
      <div class="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center mr-3">
        <svg class="w-5 h-5 text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z" />
        </svg>
      </div>
      <h3 class="text-lg font-semibold">Guides</h3>
    </div>
    <p class="text-muted-foreground">Step-by-step tutorials for common workflows and advanced features.</p>
  </a>
</div>

## What is FeedbackBin?

FeedbackBin is an open-source, self-hostable customer feedback management platform. It helps teams:

- **Collect feedback** from multiple channels and sources
- **Organize and categorize** submissions for better insights
- **Prioritize features** based on user demand and impact
- **Close the feedback loop** by keeping users informed

## Key Features

### 🏠 **Self-Hosted**
Deploy on your own infrastructure for complete data control and privacy.

### 🔓 **Open Source**
Full source code transparency with active community contributions.

### 🛠️ **Developer Friendly**
Robust API, webhooks, and integrations for seamless workflow integration.

### 🎨 **Customizable**
Adapt the platform to match your brand and workflow requirements.

## Popular Topics

<div class="grid grid-cols-1 md:grid-cols-3 gap-4 my-8">
  <a href="{{ "/docs/getting-started/installation/" | relative_url }}" class="block p-4 border border-border rounded-lg hover:bg-muted/50 transition-colors">
    <h4 class="font-medium mb-2">Installation</h4>
    <p class="text-sm text-muted-foreground">Set up FeedbackBin locally or on your server</p>
  </a>

  <a href="{{ "/docs/getting-started/configuration/" | relative_url }}" class="block p-4 border border-border rounded-lg hover:bg-muted/50 transition-colors">
    <h4 class="font-medium mb-2">Configuration</h4>
    <p class="text-sm text-muted-foreground">Configure settings and customize your instance</p>
  </a>

  <a href="{{ "/docs/api/" | relative_url }}" class="block p-4 border border-border rounded-lg hover:bg-muted/50 transition-colors">
    <h4 class="font-medium mb-2">API Reference</h4>
    <p class="text-sm text-muted-foreground">Integrate FeedbackBin with your applications</p>
  </a>
</div>

## Need Help?

- 💬 **Community Support**: [GitHub Discussions](https://github.com/{{ site.github_repository }}/discussions)
- 🐛 **Report Issues**: [GitHub Issues](https://github.com/{{ site.github_repository }}/issues)
- 📧 **Contact Us**: [hello@feedbackbin.com](mailto:hello@feedbackbin.com)

---

Ready to get started? Begin with our [Getting Started guide]({{ "/docs/getting-started/" | relative_url }}) or explore the [API documentation]({{ "/docs/api/" | relative_url }}).