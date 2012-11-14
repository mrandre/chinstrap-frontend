Chinstrap is a straightforward JS templating tool based on a few simple premises:

1. Your templates are authored and read by developers.

2. Developers are mostly familiar with code.

3. The template should be able to run code. Any deveiation from regular code should be minimal.

4. Saying your templates are logic-less is misleading, and not even appealing.

Under the hood, Chinstrap is fundamentally Jon Resig's micro templating, with a number of tweaks applied for largely aesthetic reasons, the main one being that angle brackets look too much like HTML.

So where a regular Resig template would look like:

Data: { foo : true, bar : ['dog', 'cat', 'parrot'] }

```

	<div class="body">
		<% if ( foo ) { %>
			<% for (var i=0, len=bar.length; i<len; i++) { %>
				<p><%= bar[i] %></p>	
			<% } %>
		<% } %>
	</div>
```

The chinstrap version would look like:

	<div class="body">
		{{ if (foo) { }}
			{{ for (var i=0, len=bar.length; i<len; i++ ) { }}
				<p>{{= bar[i] }}</p>
			{{ } }}
		{{ } }}
	</div>

The win: it's easier to tell the difference between markup and code. The downside: all those curly braces get a little messy. To resolve this, chinstrap employs a very thin macro system to ease legibility. But please note, the above template is perfectly valid.

A cleaner chinstrap template would be:

	<div class="body">
		{{ IF foo }}
			{{ FOR var i=0, len=bar.length; i<len; i++ }}
				<p>{{= bar[i] }}</p>
			{{ /FOR }}
		{{ /IF }}
	</div>

Notice the IF and FOR macros. When chinstrap finds either word in all caps, it takes everything after it, wraps it in parentheses, and fills in the braces as needed. You can also use the simple /FOR and /IF macros, which simply resolve to closing braces, while making iteasier to sync closers. Note that you could use a closing bracket, and it would work correctly. That is, macros are just string transposers, so you can mix and match, if that's your sort of thing.

I am a great fan of CoffeeScript, and one thing I like most is the way many things that, in straight Javascript, would be words, are symbols in Coffee. So @ in stead of this, -> instead of function. For this reason, Chinstrap has a third layer of macro-age that symbolifies certain operators. For the next example, we're going to assume some of the data is a collection object that has iteration methods (which is how my code tends to work.) Also, each member of the collection has methods to access more complex data structures. So assume the property fname has an fname method that returns that value. (Even though the data is just showing flat values )

Data: {permitted: true, people: [{ fname: 'Jack', lname: 'spratt', title: 'Mr.', job: 'Carpenter' }] }

	<div class="body">
		<ul>
		{{ ? permitted }}
			{{ WHILE people.hasMore() }}
				{{ @= people.nextItem() }}
				<li>
					{{ # Title is Optional }}
					{{ ? @title }}
						{{= @title }}&nbsp;
					{{ /? }}
					{{= @fname }}&nbsp;{{= @lname }}
					{{ ? job === 'plumber' }}
						is looking for pipes.
					{{ -? job === 'carpenter' }}
						is looking for some lumber.
					{{ - }}
						is looking for something unknown.
					{{ /? }}
				</li>
			{{ /WHILE }}
		{{ /? }}
		</ul>
	</div>

A couple of points of interest:

  * @= is a macro that creates a shortcut to whatever follows it. The main intent is iterated values, but you could use it for any object. Whenever a template encounters @ henceforth, it replaces it with the given value.

  * {{= @title }} It doesn't matter whether title is a function or a value; Chinstrap figures it out and does the right thing.

  * {{ ?, -?, - }} ? == if, -? == else if, - == else. Note that IF, ELSEIF, and ELSE are equivalent.

  * {{ # }} Is a comment, which is to say, it removes from the output, not that it translates into an HTML comment.






