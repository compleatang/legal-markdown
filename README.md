# Introduction

This gem will parse YAML Front Matter of Markdown Documents. Typically, this gem would be called with a md renderer, such as [Pandoc](http://johnmacfarlane.net/pandoc/), that would turn the md into a document such as a .pdf file or a .docx file. By combining this pre-processing with a markdown renderer, you can ensure that both the structured content and the structured styles necessary for your firm or organization are more strictly enforced. Plus you won't have to deal with Word any longer, and every lawyer should welcome that. Why? Because Word is awful.

Gitlaw is markdown agnostic (indeed, it probably does not depend on markdown, or any of its flavors at all and *should* work with ASCII or other text based documents) at this point and needs to be called independently of any markdown renderer. It is easy enough to build it into your work flow by editing the way that your markdown renderer is called. For instance you can call this file just before pandoc builds it.

## What Does the Gem Allow For?

This gem was built specifically to empower the creation of structured legal documents using markdown, and a markdown renderer. This gem acts as a middle layer by providing the user with structured headers and mixins that will greatly empower the use of md to create and maintain structured legal documents.

## How to Install This Gem?

It is very simple. But first you must have ruby installed on your system. If you are on OS X then it comes standard on your machine and you do not need to do anything. If you are on Windows then the easiest way to install ruby is install 1.9.3 or higher from [rubyinstaller](http://rubyinstaller.org/). If you are on Linux, then you don't need help. Once you have ruby installed then you simply go to your terminal and type: `$> gem install legal_markdown`.

If you are looking to try out the gem, and you use [Sublime Text](http://www.sublimetext.com/) as your text editor, then you can easily install my `legal_markdown` package by visiting the repo [here](https://github.com/compleatang/Legal-Markdown-Sublime). If you install the package there is no need to install the gem, but you will still have to install ruby.

## How to Use This Gem?

After the gem has finished its installation on your system then you can simply type `$> legal2md [filename]` where the filename is the file (in whatever flavor of markdown you use). The gem will parse the file and output the same filename.

If you prefer to output as a different filename (which will allow you to keep the YAML front-matter), then you simply type `$> legal2md [input-filename] [output-filename]`.

If you have been working on a template or document and would like the gem to build the YAML Front-Matter (see below) automatically for you, then simply type `$> legal2md --headers [filename]`.

# YAML Front-Matter

[YAML](http://www.yaml.org/spec/1.2/spec.html) is easy thing to create. At the top of your file (it MUST be at the top of the file) you simply put in three hyphens like so: `---` on a single line. Then on the next line you simply put in the `field` followed by a `:` (colon) followed by the `value`. For each line you put the `[field]: [value]` until you have filled everything in that you need. After you have put in all your YAML front-matter then you simply put in a single line with three more hyphens `---` to signal to the gem that it is the end of the fields. So this would look like this:

```
---
party1_address:    "Muj Axmed Jimcaale Road, Hargeisa, Republic of Somaliland"
party1_full:       "Watershed Legal Services, Ltd."
party1_reg:        the Republic of Somaliland
party1_rep:        "# Casey Kuhlman"
party1_short:      "(\"Watershed\")"
party1_type:       private company limited by shares
---
```

**Note**: YAML can be quite testy, so if you use any symbols or parentheses or square brackets, etc. just put the entire field inside of double quotes ("). Also, if you need double quotes within the value then you "escape" them by putting a backslash before the double quotes.

# Mixins

Mixins are straight-forward they are simple markers that can be used throughout the text to identify certain things (Court) or (Company) or (Client) to identify a few. The example above is the YAML Front Matter for mixins. This allows for the creation and utilization of templates that can be reused by simply updating the YAML front-matter.

Mixins are structured in the form of **double curly** brackets. So, for a `{{court}}` mixin within the body of your document, the YAML front-matter would look like this:

```
court: Regional Court of Hargeisa
```

If you do not want a mixin turned on for a particular document just add the mixin in the YAML Frontmatter and then leave it blank. Legal_markdown will replace the mixin with an empty string so in the parsed document it will be out of your way.

## Optional Clauses Function

When building templates for contracts, you often build in optional clauses or you build clauses that are mutually exclusive to one another. This functionality is supported by legal_markdown. Here is how to build an optional clause.

In the body of your document you put the entire clause in square-brackets (as you likely normally would) and at the beginning of the square bracket you put a mixin titled however. In the YAML Front-Matter you simply add "true" or "false" to turn that entire clause on or off. **Note**, if you do not add the mixin to your header, legal_markdown is just going to leave it as is.

You are able to nest one optional clause inside of another. However, if you do so, make sure that you include all of the sub-provisions of the master provision in the YAML matter, else legal_markdown will not be able to understand when it should close the optional provision. If you use the automatic YAML population feature either from the command line (see above) or using the Sublime package, it will simplify this process for you greatly. Another thing to note, if you include nested provisions, you can turn off an inside provision and leave an outside provision on, but if you turn off an outside provision you cannot turn on an inside provision.

So, this is how the body of the text would look.

```
[{{my_optional_clause}}Both parties agree that upon material breach of this agreement by either party they will both commit suicide in homage to Kurt Cobain.]
```

Then the YAML Front Matter would look like this

```
my_optional_clause: true
```

or

```
my_optional_clause: false
```

I don't know why you would ever write such a clause, but that is why the functionality exists!

# Structured Headers

When creating many legal documents, but especially laws and contracts, we find ourselves constantly repeating structured headers. This gets utterly maddening when working collaboratively with various word processors because each word processor has its own styles and limitations for working with ordered lists and each user of even the same word processor has different defaults. This presents a mess for those that have to clean up these lists. We waste an inordinate amount of time with "Format Painter" and other hacks that do not really allow us to focus on the text.

In order to address this problem, I have built functionality into legal_markdown that gets around this. Here is how structured headers work in the gem.

Wherever you wish to start the block of structured headers just put in ````` Three backticks (~ without the shift) at the beginning of the line. Then start the block of structured headers on the next line. When you are done with the block just put the same three backticks at the beginning of the line and continue your document.

At the beginning of the line you simply type the level in which the provision resides by the number of lowercase "l" followed by a period and then a space. So a top level provision (perhaps a Chapter, or Article depending on your document) will begin with `l. The provision ...` A second level provision (a Section or whatnot) will begin with `ll. Both parties agree ...` A third level provision will begin with `lll. Yaddy Yadda ...` And so on. These will reside in the body of the text.

When the gem parses the document it will automatically add and reset each level in the tree that you set up based on the criteria you establish.

Then you can describe the functionality that you require in the YAML front-matter. In the YAML front-matter you will simply add the following fields: `level-1` and then the `: ` followed by what the format you would like it to be in. Currently there are a few possible options at this time:

1. `level-1: 1.` will format that level of the list as 1. 2. 3. etc.; This is the default functionality;
2. `level-1: (1)` will provide for the same numbering only within parenteticals rather than followed by a period;
3. `level-1: A.` will format with capital letters followed by a period (e.g, A., B., C., etc.);
4. `level-1: (A)` will format the same as the above only with the capital letters in a parentetical;
5. `level-1: a.` will format with lowercase letters followed by a period;
6. `level-1: (a)` will format with lowercase letters within a parentethical;
7. `level-1: I.` will format with capital Roman numerals followed by a period;
8. `level-1: (I)` will format with capital Roman numerals within a parententical;
9. `level-1: i.` will format with lowercase Roman numerals followed by a period;
10. `level-1: (i)` will format with lowercase Roman numerals within a parententical..

Obviously you will replace `level-1` with `level-2`, etc.

In addition to the reference portion of the structured header, you can add in whatever text you wish. For example, if you want the top level to be articles with a number and then a period, the next level down to be sections with a number in parentheses, and the next level down to be a letter in parentheses then this is what the YAML front matter would look like.

```
---
level-1: Article 1.
level-2: Section (1)
level-3: (a)
---
```

As of version 0.2.0, you can start on any number or letter you wish. So if you want the first Article to be Article 100. instead of Article 1. there is no problem with that. One thing to be careful of if you do not start with the default numbering/lettering is that you should likely turn off the reset function for that level (see below) or else when the gem is parsing the document it will reset the level based on the default numbering/lettering rather than the initial numbering/lettering you established. Also, be careful if you want to start with letters that also match with Roman Numerals (I, V, X, L, C, D, M) whether upper or lower case as the gem parses Roman's first and if you want a sequence similar to (a), (b) but you put in (c) the gem will default to the lowercase version of the Roman Numeral C (100).

## No Reset Function

Sometimes in legal documents (particularly in laws) you want to build multiple structured header levels, but you do not want to reset all of the headers when going up the tree. For example, in some laws you will have Chapters, Parts, Sections, ... and you will want to track Chapters, Parts and Sections but when you go up to Parts you will not want to reset the Sections to one.

This functionality is built in with a `no-reset` function. You simply add a `no-reset` field to your YAML header and note the headers that you do not want to reset by their l., ll. notation. Separate those levels you do not want reset with commas. Example YAML line:

```
no-reset: l., ll., lll.
```

This will not reset level-1, level-2, or level-3 when it is parsing the document and those levels will be numbered sequentially through the entire block rather than reseting when going to a higher block, levels not in this reset, e.g., llll. and lllll. will be reset when going up a level in the tree. Obviously the level 1 headers will never reset.

## No Indent Function

If you are outputting to .pdf, .odt, .doc(x) you may want to keep some of the header levels tight to the margins. This functionality is built into legal_markdown with a `no-indent` function. You simply add a `no-indent` field to your YAML header and not the headers you do not want to indent by their l., ll. notation. Separate those levels you do not want to reset with commas as with the `no-reset` function. Any levels *below* the last level in the `no-indent` function will be indented four spaces for each level.

## Examples

The syntax should be straight-forward. If you learn by seeing rather than by reading, take a look at the Watershed lmd [repos](https://github.com/watershedlegal/commercial-documents) where we keep our contract templates for more examples. That link is for some commercial documents, but we have more on the Watershed Github page.

If you use a system like Pandoc you can establish a system wherein the styles that you establish in the reference.docx or reference.odt or the latex style references can make up for the lack of granular fuctionality. When you build your reference.odt for example and you want to have a contract look like this:

```
Article 1. Provision for Article 1.

    Section 1.1. Provision for Section 1.1.

        1.1.1 Provision for 1.1.1.

        1.1.2 Provision for 1.1.2.

    Section 1.2. Provision for Section 1.2.

        1.2.1 Provision for 1.2.1.

        1.2.2 Provision for 1.2.2.

...
```

You can easily to that by doing the following steps.

### Step 1: Type the body

```
l. Provision for Article 1.
ll. Provision for Section 1.1.
lll. Provision for 1.1.1.
lll. Provision for 1.1.2.
ll. Provision for Section 1.2.
lll. Provision for 1.2.1.
lll. Provision for 1.2.2.
```

### Step 2: (Optional) Fill out the YAML Front-Matter

```
---
level-1: 1.
level-2: A.
level-3: a.
---
```

### Step 3: Modify your reference.odt or reference.docx

In Libreoffice you would modify your template reference.odt as you need it. You would go to Format -> Bullets and Numbering -> Options.

1. First you would select Level 1 (on the left). In the Before field you would add "Article " (without the quotes, but not the space). In the After field you would add a period. In the Numbering field you would select 1, 2, 3, .... And in the Show sublevels field you would choose 1
2. Second you would select Level 2 (on the left). In the Before field you would add "Section " (without the quotes, but with the space). In the After field you would add a period. In the Numbering field you would select 1, 2, 3, .... And in the Show sublevels field you would choose 2.
3. Third you would select Level 3 (on the left). In the Before field you would add nothing (to accomplish the above desired output). In the After field you would add a period. in the Show sublevels field you would choose 3.
4. Lastly you would make sure that Consecutive Numbering (field at the bottom) was turned off.
5. You can make sure that all the indenting is as desired in the Position Tab.

Then you would save the reference.odt as a new name perhaps contract-reference.odt in your Pandoc reference folder.

### Step 3(a): Add Precursors to Headers

Within the text of the document nothing changes. In the YAML front matter you will leave it as it was before. All you need to do is add any word or other marker before the trigger. If you want to reference the preceding level (like 1.1.1 in the example above) then simply put in `pre`.So, your YAML front matter will look like this:

```
---
level-1: Article 1.
level-2: Section pre 1.
level-3: pre 1.
---
```

This is how I build most of my contracts.

### Step 3(b) Add Another Type of Precursors to Headers

Sometimes, particularly in laws, the structure is something akin to Chapter 1 and then Section 101, Section 102, ... Chapter 9, Section 901, Section 902, etc. As of version 0.2.0 you can easily adopt this structure to your document by using the `preval` feature within the YAML front matter. If you combined this structure by also using markdown headers the YAML front matter would look something like this:

```
---
level-1: "# Chapter 1."
level-2: "## Section preval 1."
level-3: pre(a)
no-indent: l., ll.
---
```

This would output (using the same text from the body of the document typed in step 1) as:

```
# Chapter 1. Provision for Article 1.

## Section 101. Provision for Section 1.1.

    101(a) Provision for 1.1.1.

    101(b) Provision for 1.1.2.

## Section 102. Provision for Section 1.2.

    102(a) Provision for 1.2.1.

    103(b) Provision for 1.2.2.

...
```

### Step 4: Run Legal-Markdown and Pandoc (or other markdown processor)

Make sure when you run Pandoc you use the new reference document that you created as the basis.

I do not use latex to create pdfs nor do I use Word, but the functionality will be similar with Word, and if you're using latex then you can figure out how to mirror this workflow.

## A Few Other Features

I find, particularly when I'm working with contracts and templates that I needed a few more features.

### Working with Cross Reference Provisions.

One thing I needed was the ability to cross reference between provisions where the text of Section 16 refers back to Section 12. When you're working with templates you may turn on or off provisions after reviewing a draft with a client. Also when you're working in a `lmd` file you do not see what the Section reference is within the document (that's the whole point). So, as of 0.2.0, there is a cross referencing feature to `legal_markdown`.

In order to try to make the gem interoperable with as many finishing renders as possible I've tried to keep the switches and symbols unique to the gem to a very few (so far within the body of the document we've only relied on square brackets and double curly braces to do all of the work). But there is only so much one can do with those symbols. So I have had to add one more symbol to get the cross-referencing right and unambiguous to the parser. Within your structured headers block simply place a reference (which you can make up and remember, it can contain letters, numbers, or symbols) within pipes "|" (the key above the enter key on US keyboards). First stake the piped reference to the provision which you want to reference to. Then other provisions can refer to it (either before or after the reference point within the document).

For example, if the YAML front matter looked like this:

```
---
level-1: "# Article 1."
level-2: "Section 1."
level-3: (a)
no-indent: l., ll.
---
```

and the body of the text looked like this:

```
...
ll. |123| This provision will need to be referenced later.
ll. Provision
lll. As stated in |123|, whatever you need to say.
...
```

would output to this:

```
Section 7. This provision will need to be referenced later.

Section 8. Provision

    (a) As stated in Section 7, whatever you need to say.
```

#### Working with Partials

In particular when I work with templates, I was realizing that it would be nice to be a bit more DRY (don't repeat yourself) in my contract building. In order to help with this, I wanted to build a partials feature. Probably not a lot of people will use this, but here is how you do it. Let's say you put your standard interpretation, notice, severance, boilerplate typically at the end of the contract just before the signature block. Let's also assume that you have multiple contract templates and they all mostly use the same boilerplate final provisions.

If you were lawyering like coders think then you would abstract these provisions into their own file within your contracts templates folder. Then you would change all of your templates to reference back to that partial. Later, if there is some change in the law you just go into the partial, make the necessary change to adopt to the change in law or interpretation, and then all of your templates which refer to that partial are automatically updated. A bit more simple then updating each and every one of your templates, eh?

Partials are simple. They use the `@import [filename]` syntax. So if your final provisions are kept in a file in the same folder called final_provisions.lmd you would put `@import final_provisions.lmd` on its own line (either within a structured headers block or outside of it) and the gem will import the contents of the partial before chewing on the whole contract. If your partial was located in another directory you just type that in just like you would on the command line `@import ~/gitlaw/contracts/commercial/partials/final_provisions.lmd` or wherever your partial is.

#### Date

When you are building documents sometime you simply want to put `effective_date: @today`. Try it! At this point it formats dates according to standard formating outside of the US. But if you want to change that, then simply add the date manually.

## A Few Gotchas

* Legal_markdown is optimized primarily for contracts, legislation, and regulations. It is not optimized for cases. For memoranda and filings I use the mixin portion but not the header portion which is enough to meet my needs - in particular, when matched with Sublime Text snippets. If you area looking for a more complete solution for cases and filings I would recommend the [Precedent Gem](https://github.com/BlackacreLabs/precedent) built by [Kyle Mitchell](https://github.com/kemitchell) for [Blackacre Labs](https://github.com/BlackacreLabs)
* At this point, you cannot have more than 9 levels for headers, but if you have more than 9 levels of headers you have some insane case study which will require more than this tool to cope with.

## Roadmap / TODO

- [X] Allow for lll. or l3. leaders based on leader-style: l. or leader-style: l1. switch in YAML.
- [X] Implement partials as `@include filename`.
- [X] Implement internal cross references as `ll. |123| Provision`
- [X] Different starting values.
- [X] Pre-VALUE functionality where Article 1 subs to 101.
- [X] Handle exceptions better as it is very brittle right now.
- [X] YAML Maker.
- [ ] md2lmd functionality. At this point legal_markdown cannot take a markdown document and parse it to build a structured legal document. Legal_markdown only works with a renderer to *create* documents but not to *parse* legal documents to create markdown.

If you have needs that you think other people may have, feel free to put them up in the Github issues.

# Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Add Tests (and feel free to help here since I don't (yet) really know how to do that.).
4. Commit your changes (`git commit -am 'Add some feature'`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create new Pull Request.

# License

MIT License - (c) 2013 - Watershed Legal Services, PLLC. All copyrights are owned by [Watershed Legal Services, PLLC](http://watershedlegal.com). See License file.

This software is provided as is and specifically disclaims any implied warranties of fitness for any purpose whatsoever. By using this software you agree to hold harmless Watershed Legal Services and its Members for any perceived harm that using this software may have caused you.

In other words, don't be a jerk.