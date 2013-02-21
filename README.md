# Introduction

This gem will parse YAML Front Matter of Markdown Documents. Typically, this gem would be called with a md renderer, such as [Pandoc](http://johnmacfarlane.net/pandoc/), that would turn the md into a document such as a .pdf file or a .docx file. By combining this pre-processing with a markdown renderer, you can ensure that both the structured content and the structured styles necessary for your firm or organization are more strictly enforced. Plus you won't have to deal with Word any longer, and every lawyer should welcome that. Why? Because Word is awful. 

Gitlaw is markdown agnostic at this point and needs to be called independently of any markdown renderer. It is easy enough to build it into your work flow by editing the way that your markdown renderer is called. For instance you can call this file just before pandoc builds it. I use Sublime Text 2 with the Pandown plugin to build my Pandoc files. So what I would do is [..TODO..].

## What Does the Gem Allow For?

This gem was built specifically to empower the creation of structured legal documents using markdown, and a markdown renderer. This gem acts as a middle layer by providing the user with structured headers and mixins that will greatly empower the use of md to create and maintain structured legal documents.

## How to Install This Gem?

It is very simple. But first you must have ruby installed on your system. (Google it) Once you have ruby installed then you simply go to your terminal and type: `$> gem install legal_markdown`. 

## How to Use This Gem?

After the gem has finished its installation on your system then you can simply type `$> legalmd [filename]` where the filename is the file (in whatever flavor of markdown you use). The gem will parse the file and output the same filename. If you prefer to output as a different filename (which will allow you to keep the YAML front-matter), then you simply type `$> legalmd [input-filename] [output-filename]`. 

# YAML Front-Matter

[YAML](http://www.yaml.org/spec/1.2/spec.html) is about the easiest thing to create. At the top of your file (it MUST be at the top of the file) you simply put in three or more hyphens like so: `---` on a single line. Then on the next line you simply put in the `field` followed by a `:` (colon) followed by the `value`. For each line you put the `[field]: [value]` until you have filled everything in that you need. After you have put in all your YAML front-matter then you simply put in a single line with three more hyphens `---` to signal to the gem that it is the end of the fields. So this would look like this:

    ```yaml
    ---
    title: My Perfect Contract
    author: Watershed Legal Services
    date: 2013-01-01
    ---
    ```

## A Few Signals to the Parser

### Leaving the YAML Front-Matter

The gem will normally strip out the YAML front-matter as most markdown renderers will not be sure what to do with such content. Indeed, pandoc will end up drawing a table with the data still there. However, because some could potentially want to use this gem in combination with something like [Jekyll](https://github.com/mojombo/jekyll/) or any other system that could use the YAML front-matter there is a special trigger that tells legal_markdown to leave the YAML front-matter in the file. Legal_markdown will still make the necessary changes to the text of the file but it will not strip out the YAML front-matter in the process of making those changes. 

To leave the YAML front-matter there simply pass the `value` of `true` to the `field` called `leave_yaml_front_matter`; this is how it would look in the above example. 

    ```yaml
    ---
    title: My Perfect Contract
    author: Watershed Legal Services
    date: 2013-01-01
    leave_yaml_front_matter: true
    ---
    ```

If you do not add the `true` value to the field then the default which is set to false will be triggered and the YAML Front-Matter will be stripped.

### Some Pandoc-Specific Fields

There are a few fields that will be treated uniquely. The three fields in the example above (title: , author: , and date: ) will be replaced with the Pandoc fields as appropriate. Perhaps later we can (as a community) build out this functionality for other renderers but for now I've only built it to use Pandoc. If you don't use Pandoc then you can simply omit these fields and there will be no problem. 

# Mixins

Mixins are straight-forward they are simple markers that can be used throughout the text to identify certain things (Court) or (Company) or (Client) to identify a few. This allows for the creation and utilization of templates that can be reused by simply updating the YAML front-matter.

Mixins are structured in the form of **double curly** brackets (this was taken from IFTTT). So, for a `{{court}}` mixin, the YAML front-matter would look like this:

    ```yaml
    {{court}}: Regional Court of Hargeisa
    ```

Mixins can also be used to set up clauses in the alternative in your templates which can be turned on or off within a specific document simply by updating the YAML mixin to false. Example of a `{{provision12a}}{{provision12b}}` alternative structuring for a contract template. Within the template the YAML front-matter would be structured something like this:

    ```yaml
    {{provision12a}}: "For the purposes of this Agreement"
    {{provision12b}}: "This Agreement shall"
    ```

Then to chose one of the two provisions you would would simply change the line to "false" but without the quotes. Example:

    ```yaml
    {{provision12a}}: false
    ```

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

## Example

If you use a system like Pandoc you can establish a system wherein the styles that you establish in the reference.docx or reference.odt or the latex style references can make up for the lack of granular fuctionality. When you build your reference.odt for example and you want to have a contract look like this:

Article 1. Provision for Article 1.

  Section 1.1. Provision for Section 1.1. 

    1.1.1 Provision for 1.1.1.

    1.1.2 Provision for 1.1.2.

  Section 1.2. Provision for Section 1.2.

    1.2.1 Provision for 1.2.1.

    1.2.2 Provision for 1.2.2.

...

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

    ```yaml
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

    ```yaml
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

You cannot begin the block of structured headers with a second level header. The gem searches the markdown to find a line that begins with `l.` where there is a blank line above it. This is made to be fairly precise so as to ensure that the gem does not strip out some other functionality that you want to build. 

When you are using structured headers of legal_markdown you should make the lists tight. Do not add blank lines in between the list levels or the gem will think you are creating a new list. If you are trying to create a new list then by all means go ahead as the blank lines will break the parsing. 

Also, if you use the reference.odt or reference.docx to override the default formating of the list then you do not need to add any level-1 or level-2 fields to the YAML front-matter. The best way to do it is to simply use the defaults that pandoc or your renderer will use and then use the reference styles to build the functionality that you would like. 

# TODO

[ ] - Definitions. For now these can be used as mixins but that functionality needs to improve.

[ ] - Parsing. At this point legal_markdown cannot take a markdown document and parse it to build structured headers. Legal_markdown only works with a renderer to *create* documents but not to *import* documents. I want to build this functionality out at a later date. Legal_markdown is not meant as an importer for files types, there are other tools for that but I would like it to be able to parse text that is already in markdown. 

[ ] - Markdown post-processing. This will cure some of the issues (class establishment and proper list nesting of structure documents) that are currently lost when using precurors.

[ ] - Different input and output files

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# License

MIT License - (c) 2012 - Watershed Legal Services, PLLC. All copyrights are owned by [Watershed Legal Services, PLLC](http://watershedlegal.com). See License file.

This software is provided as is and specifically disclaims any implied warranties of fitness for any purpose whatsoever. By using this software you agree to hold harmless Watershed Legal Services and its Members for any perceived harm that using this software may have caused you. 

In other words, don't be a jerk. 