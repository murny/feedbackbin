---
layout: docs
title: Deployment Overview
description: "Choose the best deployment method for FeedbackBin: Kamal for zero-downtime deployments or Docker for custom setups."
---

## Deployment Methods

<div class="grid grid-cols-1 md:grid-cols-2 gap-6 my-8">
  <a href="{{ "/docs/getting-started/deployment/kamal/" | relative_url }}" class="group flex gap-4 p-6 bg-card border border-border rounded-lg hover:shadow-lg transition-all duration-200 hover:border-primary/50">
    <div class="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center group-hover:bg-primary/20 transition-colors flex-shrink-0 mt-8">
      <svg class="w-6 h-6 text-primary" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" />
      </svg>
    </div>
    <div>
      <h3 class="text-lg font-semibold mb-2 group-hover:text-primary transition-colors">Kamal Deployment</h3>
      <p class="text-muted-foreground text-sm leading-relaxed">
        <strong>Simple:</strong> Automated deployment tooling with built-in best practices for zero-downtime deployments and SSL management.
      </p>
    <div class="mt-4">
      <div class="flex flex-wrap gap-2">
        <span class="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full">Easy Setup</span>
        <span class="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">Built-in SSL</span>
        <span class="px-2 py-1 bg-purple-100 text-purple-800 text-xs rounded-full">Automated</span>
      </div>
    </div>
    </div>
  </a>

  <a href="{{ "/docs/getting-started/deployment/docker/" | relative_url }}" class="group flex gap-4 p-6 bg-card border border-border rounded-lg hover:shadow-lg transition-all duration-200 hover:border-primary/50">
    <div class="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center group-hover:bg-primary/20 transition-colors flex-shrink-0 mt-8">
      <svg class="w-6 h-6 text-primary" fill="currentColor" viewBox="0 0 24 24">
        <path d="M13.983 11.078h2.119a.186.186 0 00.186-.185V9.006a.186.186 0 00-.186-.186h-2.119a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.185m-2.954-5.43h2.118a.186.186 0 00.186-.186V3.574a.186.186 0 00-.186-.185h-2.118a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.186m0 2.716h2.118a.187.187 0 00.186-.186V6.29a.186.186 0 00-.186-.185h-2.118a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.186m-2.93 0h2.12a.186.186 0 00.184-.186V6.29a.185.185 0 00-.185-.185H8.1a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.186m-2.964 0h2.119a.186.186 0 00.185-.186V6.29a.185.185 0 00-.185-.185H5.136a.186.186 0 00-.186.185v1.888c0 .102.084.185.186.186m5.893 2.715h2.118a.186.186 0 00.186-.185V9.006a.186.186 0 00-.186-.186h-2.118a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.185m-2.93 0h2.12a.185.185 0 00.184-.185V9.006a.185.185 0 00-.184-.186h-2.12a.185.185 0 00-.184.185v1.888c0 .102.083.185.185.185m-2.964 0h2.119a.185.185 0 00.185-.185V9.006a.185.185 0 00-.184-.186h-2.12a.186.186 0 00-.186.186v1.887c0 .102.084.185.186.185m0 2.715h2.119a.185.185 0 00.185-.185v-1.888a.185.185 0 00-.184-.185h-2.12a.185.185 0 00-.185.185v1.888c0 .102.084.185.186.185m8.027-2.715h2.118a.186.186 0 00.186-.185V9.006a.186.186 0 00-.186-.186h-2.118a.186.186 0 00-.186.186v1.887c0 .102.084.185.186.185m2.118-2.715a.186.186 0 00.186-.186V6.29a.185.185 0 00-.186-.185h-2.118a.186.186 0 00-.186.185v1.888c0 .102.084.185.186.186h2.118zm4.49 2.715h-7.32a.185.185 0 00-.185.185v1.888c0 .102.083.185.185.185h7.32c.924 0 1.67.746 1.67 1.67 0 .924-.746 1.67-1.67 1.67h-15.52C1.746 15.457 1 14.711 1 13.787c0-.924.746-1.67 1.67-1.67h.185c.102 0 .185-.083.185-.185 0-2.772 2.248-5.02 5.02-5.02.924 0 1.848.264 2.587.742.185.12.435.024.435-.185V5.647c0-.102.083-.185.185-.185h2.119c.102 0 .185.083.185.185v1.888c0 .102.083.185.185.185h2.119c.102 0 .185-.083.185-.185V5.647c0-.102.083-.185.185-.185h2.119c.102 0 .185.083.185.185v1.888c0 .102.083.185.185.185h2.119c.102 0 .185-.083.185-.185V5.647c0-.102.083-.185.185-.185h2.119c.102 0 .185.083.185.185v1.888c0 .102.083.185.185.185h.924c.924 0 1.67.746 1.67 1.67 0 .924-.746 1.67-1.67 1.67z"/>
      </svg>
    </div>
    <div>
      <h3 class="text-lg font-semibold mb-2 group-hover:text-primary transition-colors">Docker Deployment</h3>
      <p class="text-muted-foreground text-sm leading-relaxed">
        <strong>Flexible:</strong> Manual setup with Docker containers for custom configurations, Kubernetes integration, and full control.
      </p>
    <div class="mt-4">
      <div class="flex flex-wrap gap-2">
        <span class="px-2 py-1 bg-orange-100 text-orange-800 text-xs rounded-full">Full Control</span>
        <span class="px-2 py-1 bg-indigo-100 text-indigo-800 text-xs rounded-full">Kubernetes</span>
        <span class="px-2 py-1 bg-gray-100 text-gray-800 text-xs rounded-full">Custom Setup</span>
      </div>
    </div>
    </div>
  </a>
</div>

## Which Method Should I Choose?

### Choose Kamal if you want:

- **Minimal setup complexity** - Automated deployment workflow out of the box
- **Opinionated best practices** - SSL, zero-downtime, and rollbacks handled automatically
- **Quick start** - Deploy to VPS or cloud instances without complex orchestration
- **Built-in conveniences** - Health checks, logging, and asset management included

### Choose Docker if you need:

- **Integration with existing infrastructure** - Work with current Docker/Kubernetes setups
- **Custom orchestration** - Use your preferred container orchestration platform
- **Granular control** - Configure every aspect of the deployment pipeline
- **Enterprise requirements** - Complex networking, multiple databases, or custom security policies
- **Team expertise** - Leverage existing Docker/DevOps knowledge and tooling