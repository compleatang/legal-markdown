# Introduction

This gem will parse YAML Front Matter of Markdown Documents. Typically, this gem would be called with a md renderer, such as [Pandoc](http://johnmacfarlane.net/pandoc/), that would turn the md into a document such as a .pdf file or a .docx file. By combining this pre-processing with a markdown renderer, you can ensure that both the structured content and the structured styles necessary for your firm or organization are more strictly enforced. Plus you won't have to deal with Word any longer, and every lawyer should welcome that. Why? Because Word is awful. 

Gitlaw is markdown agnostic at this point and needs to be called independently of any markdown renderer. It is easy enough to build it into your work flow by editing the way that your markdown renderer is called. For instance you can call this file just before pandoc builds it. 

## What Does the Gem Allow For?

This gem was built specifically to empower the creation of structured legal documents using markdown, and a markdown renderer. This gem acts as a middle layer by providing the user with structured headers and mixins that will greatly empower the use of md to create and maintain structured legal documents.

## How to Install This Gem?

It is very simple. But first you must have ruby installed on your system. (Google it) Once you have ruby installed then you simply go to your terminal and type: `$> gem install legal_markdown`. 

## How to Use This Gem?

After the gem has finished its installation on your system then you can simply type `$> md2legal [filename]` where the filename is the file (in whatever flavor of markdown you use). The gem will parse the file and output the same filename. If you prefer to output as a different filename (which will allow you to keep the YAML front-matter), then you simply type `$> md2legal [input-filename] [output-filename]`. 

# YAML Front-Matter

[YAML](http://www.yaml.org/spec/1.2/spec.html) is about the easiest thing to create. At the top of your file (it MUST be at the top of the file) you simply put in three or more hyphens like so: `---` on a single line. Then on the next line you simply put in the `field` followed by a `:` (colon) followed by the `value`. For each line you put the `[field]: [value]` until you have filled everything in that you need. After you have put in all your YAML front-matter then you simply put in a single line with three more hyphens `---` to signal to the gem that it is the end of the fields. So this would look like this:

```
---
title: My Perfect Contract
author: Watershed Legal Services
date: 2013-01-01
---
```

## Some Pandoc-Specific Fields

There are a few fields that will be treated uniquely. The three fields in the example above (title: , author: , and date: ) will be replaced with the Pandoc fields as appropriate. Perhaps later we can (as a community) build out this functionality for other renderers but for now I've only built it to use Pandoc. If you don't use Pandoc then you can simply omit these fields and there will be no problem. 

# Mixins

Mixins are straight-forward they are simple markers that can be used throughout the text to identify certain things (Court) or (Company) or (Client) to identify a few. This allows for the creation and utilization of templates that can be reused by simply updating the YAML front-matter.

Mixins are structured in the form of **double curly** brackets (this was taken from IFTTT). So, for a `{{court}}` mixin, the YAML front-matter would look like this:

```
{{court}}: Regional Court of Hargeisa
```

If you do not want a mixin turned on for a particular document just add the mixin in the YAML Frontmatter and then leave it blank. Legal_markdown will replace the mixin with an empty string so in  the parsed document it will be out of your way.

# Structured Headers

When creating many legal documents, but especially laws and contracts, we find ourselves constantly repeating structured headers. This gets utterly maddening when working collaboratively with various word processors because each word processor has its own sytles and limitations for working with ordered lists and each user of even the same word processor has different defaults. This presents a mess for those that have to clean up these lists. We waste an inordinate amount of time with "Format Painter" and other hacks that do not really allow us to focus on the text. 

In order to address this problem, I have built functionality into legal_markdown that gets around this. Here is how structured headers work in the gem. At the beginning of the line you simply type the level in which the provision resides by the number of lowercase "l" followed by a period and then a space. So a top level provision (perhaps a Chapter, or Article depending on your document) will begin with `l. The provision ...` A second level provision (a Section or whatnot) will begin with `ll. Both parties agree ...` A third level provision will begin with `lll. Yaddy Yadda ...` And so on. These will reside in the body of the text. 

Then you can describe the functionality that you require in the YAML front-matter. In the YAML front-matter you will simply add the following fields: `level-1` and then the `: ` followed by what the format you would like it to be in. Currently there are a few possible options at this time (for those using pandoc at least): 

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

Obviously you will replace `level-1` with `level-2`, etc. Although this functionality was built into the gem, it is generally not the best practice. A better practice is to let the gem make the replacements and reformat the markdown and then use your rendering system and its default reference documents to set the styles you need. 

**Update**: Have updated the block slightly so that it will work better with blank lines and multiple paragraph blocks. Wherever you wish to start the block just put in ````` Three backticks (~ without the shift) at the beginning of the line. Then start the block on the next line -- don't skip a blank line. When you are done with the block just put the same three backticks at the beginning of the line and continue your document.

## No Reset Function

Sometimes in legal documents (particularly in laws) you want to build multiple structured header levels, but you do not want to reset all of the headers when going up the tree. For example, in some laws you will have Chapters, Parts, Sections, ... and you will want to track Chapters, Parts and Sections but when you go up to Parts you will not want to reset the Sections to one. 

This functionality is built in with a `no-reset` function. You simply add a `no-reset` field to your YAML header and note the headers that you do not want to reset by their l., ll. notation. Separate those levels you do not want reset with commas. Example YAML line:

```
no-reset: l., ll., lll.
```

This will not reset level-1, level-2, or level-3 when it is parsing the document and those levels will be numbered sequentially through the entire block rather than reseting when going to a higher block, levels not in this reset, e.g., llll. and lllll. will be reset when going up a level in the tree. Obviously the level 1 headers will never reset.

## No Indent Function

Sometimes you will not want to use Pandoc's listing function. Basically if you are outputting to .pdf, .odt, .doc(x) you may want to keep tight to the margins. This functionality is built into legal_markdown with a `no-indent` function. You simply add a `no-ident` field to your YAML header and not the headers you do not want to indent by their l., ll. notation. Separate those levels you do not want to reset with commas as with the `no-reset` function. Any levels *below* the last level in the `no-indent` function will be indented four spaces.

## Optional Clauses Function

When building templates for contracts, you often build in optional clauses or you build clauses that are mutually exclusive to one another. This functionality is supported by legal_markdown. This is how you build an optional clause. In the body of your text you put the entire clause in square-brackets (as you likely normally would) and at the beginning of the square bracket you put a mixin titled however. In the YAML Front-Matter you simply add true or false to turn that entire clause on or off. **Note**, if you do not add the mixin to your header, legal_markdown is just going to leave it as is. 

You are able to nest one optional clause inside of another. However, if you do so, make sure that you include all of the sub-provisions of the master provision in the YAML matter, else legal_markdown will not be able to understand when it should close the optional provision. Another thing to note, if you include nested provisions, you can turn off an inside provision and leave an outside provision on, but if you turn off an outside provision you cannot turn on an inside provision.

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

## Build the YAML Frontmatter

Want to let `legal_markdown` build and sort your YAML Front Matter for you? No problem. Simply call the executable from the command line with `--headers FILENAME` and it is done. 

## Example

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
title: Wonderful Contract
author: Your Name
date: today
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

*Note*: I only use these when I'm using pandoc to move directly to html or pdf files (a fuller suite of this is what we're working towards at Watershed, along with the fantastic team at [FrontlineSMS](http://www.frontlinesms.com/about-us/) and others hopefully). If you want to use `legal_markdown` along with .odt or .docx files probably better to utilize the workflow described *supra*.

Now that you've been warned, here's how you use precursors. Within the text of the document nothing changes. In the YAML front matter you will leave it as it was before. All you need to do is add any word or other marker before the trigger. What `legal_markdown` will do is to look at the last two characters if the marker ends in a period or three if it ends in a paren, and then everything else it will place into a precursor. If you want to reference the preceding level (like 1.1.1 in the example above) then simply put in {pre}. I'll try to make this less fragile down the road, but for now it is what it is. So, your YAML front matter will look like this:

```
---
title: Wonderful Contract
author: Your Name
date: today
level-1: Article 1.
level-2: pre 1.
level-3: pre a.
---
```

The other thing you need to be aware of if you use this method is that when `legal_markdown` parses the input markdown it have to hardcode in the numbering. This means that you'll lose any features of automatic lists and list nesting which your markdown renderer may give you if you simply placed the triggers without any precursors.

### Step 4: Run Legal-Markdown and Pandoc

Make sure when you run Pandoc you use the new reference document that you created as the basis. 

I do not use latex to create pdfs nor do I use Word, but the functionality will be similar with Word, and if you're using latex then you can figure out how to mirror this workflow.

## A Few Gotchas

* When you are using structured headers of legal_markdown you should make the lists tight. Do not add blank lines in between the list levels or the gem will think you are creating a new list. If you are trying to create a new list then by all means go ahead as the blank lines will break the parsing. On the roadmap is functionality for multiple blocks, but at this point in the Gem's development it will only run one block through the modification methods. 
* If you use the reference.odt or reference.docx to override the default formating of the list then it is not optimal add level-1 or level-2 leading text or utilize the different marker functionality (e.g., (i) or (a) and the like) to the YAML front-matter. The optimal way is to use the defaults that pandoc has or whatever renderer you use along with legal_markdown to set the spacing and then use the reference styles to build the functionality that you would like from the word processor side. The leading text and different marker systems are predominately built for html output.
* Legal_markdown is optimized primarily for contracts, legislation, and regulations. It is not optimized for cases. For memoranda and filings I use the mixin portion but not the header portion which is enough to meet my needs - in particular, when matched with Sublime Text snippets. If you area looking for a more complete solution for cases and filings I would recommend the [Precedent Gem](https://github.com/BlackacreLabs/precedent) built by [Kyle Mitchell](https://github.com/kemitchell) for [Blackacre Labs](https://github.com/BlackacreLabs)

# Roadmap / TODO

- [X] Make a no-reset option for certain levels that should not reset when moving up the tree.
- [X] Make no indent option.
- [X] Optional clauses in brackets with a mixin inside. Turn the mixin to false and the whole clause will not be rendered. For a mixin that simply turns on or off, must make a function whereby the mixin is true that it is turned on. 
- [X] Handle against multiple blocks in a document as this currently will not work.
- [X] Different input and output files.
- [X] Function to build the YAML Front Matter
- [ ] Implement partials.
- [ ] Date = today function.
- [ ] Final scan of the document to remove double spaces and space-periods (guard for nil mixins which had space in template).
- [ ] Handle Exceptions better as it is very brittle right now.
- [ ] Leave the YAML Front Matter
- [ ] Definitions. For now these can be used as mixins but that functionality needs to improve.
- [ ] legal2md functionality. At this point legal_markdown cannot take a markdown document and parse it to build a structured legal document. Legal_markdown only works with a renderer to *create* documents but not to *parse* legal documents to create markdown. 
- [ ] ??? Should this switch to TOML rather than YAML frontmatter...?
- [ ] If one subheading, turn off option.
- [ ] Switch to a l1, l2, l3 style as will be faster to parse.

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